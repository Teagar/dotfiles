import {
  choice,
  noul,
  score,
  TypeSafeClient,
  type ChoiceCriteria,
  type EntryType,
  type ScoreCriteria,
} from "@typesafe-ai/sdk"
import { tool } from "@opencode-ai/plugin"

const jsonValue = tool.schema.json()
const entryValue = tool.schema.union([
  tool.schema.string(),
  tool.schema.record(tool.schema.string(), jsonValue),
  tool.schema.array(jsonValue),
  tool.schema.null(),
])

const question = tool.schema.discriminatedUnion("type", [
  tool.schema.object({
    type: tool.schema.literal("choice"),
    instructions: entryValue.describe("A narrow semantic decision as text or structured JSON."),
    criteria: tool.schema
      .record(tool.schema.string(), entryValue.nullable())
      .refine((criteria) => {
        const count = Object.keys(criteria).length
        return count >= 2 && count <= 255
      }, {
        message: "Choice requires between 2 and 255 alternatives.",
      })
      .describe("Known alternatives mapped to descriptions, or null when a label is self-explanatory."),
  }),
  tool.schema.object({
    type: tool.schema.literal("score"),
    instructions: entryValue.describe("One narrow dimension to score."),
    criteria: tool.schema
      .array(entryValue.nullable())
      .min(2)
      .max(10)
      .describe("Ordered rubric levels from lowest (index 0) to highest."),
  }),
  tool.schema.object({
    type: tool.schema.literal("noul"),
    instructions: entryValue.describe("A focused yes/no statement or question."),
    criteria: tool.schema
      .object({
        true: entryValue.optional(),
        false: entryValue.optional(),
      })
      .optional()
      .describe("Optional descriptions of what true and false mean."),
  }),
])

const safeError = (error: unknown): { name: string; message: string } => {
  if (error instanceof Error) {
    return { name: error.name || "Error", message: error.message }
  }
  return { name: "Error", message: "Unknown TypeSafe API error." }
}

export default tool({
  description:
    "Optional Jev/TypeSafe helper for small, atomic semantic decisions: classification, ranking, scoring, or choosing among known alternatives. Use only when semantic judgment adds value. Do not use when deterministic code, text search, file reading, or another normal tool can solve the task directly. A failure is non-blocking; continue without Jev.",
  args: {
    state: entryValue.describe("The text or structured JSON that every question evaluates."),
    questions: tool.schema
      .record(tool.schema.string(), question)
      .refine((questions) => Object.keys(questions).length > 0, {
        message: "Provide at least one named question.",
      })
      .describe("Named Choice, Score, and/or Noul questions evaluated independently in one request."),
    model: tool.schema
      .string()
      .optional()
      .describe("Optional official model override. Defaults to jev-latest."),
  },
  async execute(args, context) {
    const apiKey = (globalThis as { process?: { env?: Record<string, string | undefined> } }).process
      ?.env?.TYPESAFE_API_KEY
    if (!apiKey?.trim()) {
      return JSON.stringify({
        ok: false,
        recoverable: true,
        error: {
          code: "missing_api_key",
          message: "TYPESAFE_API_KEY is not configured. Continue without Jev.",
        },
      })
    }

    try {
      const questions = Object.fromEntries(
        Object.entries(args.questions).map(([name, item]) => {
          if (item.type === "choice") {
            return [
              name,
              choice(item.instructions as EntryType, item.criteria as ChoiceCriteria),
            ]
          }
          if (item.type === "score") {
            return [
              name,
              score(item.instructions as EntryType, item.criteria as unknown as ScoreCriteria),
            ]
          }
          return [name, noul(item.instructions as EntryType, item.criteria as Parameters<typeof noul>[1])]
        }),
      )

      const client = new TypeSafeClient({
        timeout: 10_000,
        logLevel: "off",
        retry: { maxRetries: 0 },
      })
      const result = await client.systemOne({
        state: args.state as EntryType,
        questions,
        ...(args.model ? { model: args.model } : {}),
      }, {
        signal: context.abort,
        timeout: 10_000,
      })

      return JSON.stringify({ ok: true, ...result })
    } catch (error) {
      return JSON.stringify({
        ok: false,
        recoverable: true,
        error: {
          code: "typesafe_unavailable",
          ...safeError(error),
          message: `${safeError(error).message} Continue without Jev.`,
        },
      })
    }
  },
})
