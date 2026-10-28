# Configuracao do Niri

`config.kdl` e o ponto de entrada. Os arquivos estao separados por responsabilidade:

- `config/`: entrada, teclado, layout, inicializacao, atalhos e workspaces.
- `config/rules/`: regras de janela agrupadas por tipo de aplicativo.
- `output/`: perfis de monitores; escolha um no include de `config.kdl`.
- `extra/`: integracoes visuais opcionais.
- `plugins/`: configuracoes geradas ou mantidas por integracoes externas.
- `scripts/`: automacoes auxiliares.

Valide alteracoes com:

```sh
niri validate -c ~/.config/niri/config.kdl
```
