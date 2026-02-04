# AGENTS.md

## Build/Lint/Test Commands

### Sintaxe Bash
```bash
bash -n git-clean.sh
```

### Testes Locais (antes de instalar)
```bash
./git-clean.sh --help
./git-clean.sh --version
./git-clean.sh
```

### Teste Manual Completo
1. Criar branch de teste: `git checkout -b feature/test-branch`
2. Fazer merge no main: `git checkout main && git merge feature/test-branch`
3. Executar: `./git-clean.sh`
4. Verificar que o branch foi removido: `git branch`
5. Criar branch sem merge: `git checkout -b feature/unmerged`
6. Executar: `./git-clean.sh`
7. Verificar que o branch NÃO foi removido

## Code Style Guidelines

### Shebang e Estrutura
- `#!/bin/bash` na primeira linha
- Comentários descritivos em português nas primeiras linhas
- Variáveis globais (UPPER_CASE) logo após comentários

### Indentação
- Usar **tabs** (1 tab level) para indentação
- Linha em branco entre seções principais

### Strings e Variáveis
- Sempre aspas duplas: `"$VAR"`
- Usar `${VAR}` quando houver ambiguidade
- Variáveis globais: `GITHUB_REPO`, `RAW_URL`, `CONFIG_DIR`, `CONFIG_FILE`, `MAIN_BRANCH`

### Condicionais e Estruturas
- `if [ "$VAR" = "value" ]; then` (espaços obrigatórios em `[` e `]`)
- Operadores lógicos: `&&` para and, `||` para or
- `|| true` para comandos que podem falhar sem erro

### Tratamento de Erros
- `set -e` após parsing de argumentos (não antes)
- Verificar dependências: `command -v curl &>/dev/null`
- Saídas com erro: `echo "Erro: descrição" && exit 1`
- Redirecionar stderr para /dev/null quando necessário: `2>/dev/null`

### Mensagens e Output
- Prefixos de seção: `=== Título ===`
- Ícones: `✓` para sucesso, `✗` para erro/atenção
- Mensagens descritivas em português
- `echo` com aspas duplas para todas as mensagens
- Uma linha em branco após cada seção importante

### Convenções de Nomes
- Variáveis: `UPPER_CASE`
- Funções (se houver): `lowercase_with_underscores`
- Arquivos de script: `kebab-case.sh`

### Estrutura do Script
1. Shebang (`#!/bin/bash`)
2. Comentários descritivos (2-3 linhas)
3. Variáveis globais
4. Parsing de argumentos (--help, --version, --upgrade)
5. `set -e`
6. Configuração (CONFIG_DIR, CONFIG_FILE, mkdir)
7. Lógica principal com mensagens progressivas
8. Mensagens de conclusão

### Segurança
- Sempre usar `"$VAR"` (aspas duplas em variáveis expandidas)
- Verificar existência de arquivos/diretórios antes de acessar
- Usar `git branch -d` (safe delete) nunca `git branch -D`
- Dupla verificação antes de ações destrutivas
- Redirecionar output sensível para /dev/null

### Git Commands
- `git branch --merged <branch>` para listar branches mergeados
- `git merge-base --is-ancestor <branch> <target>` para verificar merge
- `git show-ref --verify --quiet <ref>` para verificar existência
- `git branch -d <branch>` para deletar local (safe)
- `git push origin --delete <branch>` para deletar remoto

### URLs e APIs
- GitHub API: `https://api.github.com/repos/<owner>/<repo>/releases/latest`
- Raw content: `https://raw.githubusercontent.com/<owner>/<repo>/refs/heads/main/<file>`
- SHA256 para verificação de atualizações

### Arquivos de Configuração
- Diretório: `$HOME/.config/git-clean`
- Arquivo: `settings.json`
- Formato: `{"main_branch": "main"}`
