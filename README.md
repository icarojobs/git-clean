# Git Clean

Um script Bash simples e seguro para remover branches locais e remotos que já foram mergeados no branch principal remoto.

## 📋 Sobre

O `git-clean` é uma ferramenta que automatiza a limpeza de branches que já não são mais necessários. Ele identifica todos os branches locais que estão mergeados no branch principal configurado (`main`, `master`, `production`, etc.) e remove-os tanto do repositório local quanto do remoto, mantendo seu workspace organizado.

## ⚠️ Importante

Este script é **muito cuidadoso** e só remove branches que estão **realmente** mergeados no branch principal configurado. Ele realiza dupla verificação antes de deletar qualquer branch, garantindo que você não perderá trabalho.

Na **primeira execução**, o script perguntará "Informe o nome do branch de produção:" para que você possa definir qual é o seu branch principal (ex: `main`, `master`, `production`). Essa configuração será salva em `~/.config/git-clean/settings.json` e reutilizada nas próximas execuções.

## 📦 Pré-requisitos

- Sistema operacional Linux, macOS ou Unix-like
- Git instalado e configurado
- `curl` instalado (necessário para verificar a versão com `--version`)
- Permissões de administrador/sudo (para instalar o script globalmente)

## 🔧 Instalação

### Método 1: Instalar no `/usr/local/bin` (Requer sudo)

```bash
# Clone ou baixe o repositório
git clone <url-do-repositorio> git-clean
cd git-clean

# Copie o script para o diretório bin
sudo cp git-clean.sh /usr/local/bin/git-clean

# Dê permissão de execução
sudo chmod +x /usr/local/bin/git-clean
```

### Método 2: Instalar no `~/bin` (Sem sudo)

```bash
# Crie o diretório ~/bin se não existir
mkdir -p ~/bin

# Clone ou baixe o repositório
git clone <url-do-repositorio> git-clean
cd git-clean

# Copie o script
cp git-clean.sh ~/bin/git-clean

# Dê permissão de execução
chmod +x ~/bin/git-clean

# Adicione ~/bin ao PATH (adicione ao seu ~/.bashrc ou ~/.zshrc)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Verificar instalação

```bash
git-clean --help
# Ou simplesmente
which git-clean
```

## 🚀 Como Usar

### Comandos Disponíveis

- `git-clean` - Executa a limpeza de branches mergeados
- `git-clean --help` ou `git-clean -h` - Exibe a mensagem de ajuda
- `git-clean --version` ou `git-clean -v` - Exibe a versão atual do script

### Uso Básico

1. Navegue até a raiz do seu projeto Git
2. Certifique-se de estar em um diretório que contenha a pasta `.git`
3. Execute o comando:

```bash
git-clean
```

**Primeira execução:**
```
=== Configuração inicial ===
Informe o nome do branch de produção:
> main

Configuração salva em: /home/usuario/.config/git-clean/settings.json

=== Iniciando limpeza de branches mergeados no origin/main ===

Fazendo checkout no main e atualizando...
Already on 'main'
Already up to date.

Atualizando informações remotas...

Verificando branches locais (excluindo main e HEAD)...
...
```

A configuração será salva automaticamente e você não precisará informar novamente nas próximas execuções.

## 📝 O que o script faz

1. **Verifica configuração** - Na primeira execução, pede o nome do branch principal e salva em `~/.config/git-clean/settings.json`
2. **Faz checkout no branch principal** e atualiza (`git checkout <branch> && git pull`)
3. **Atualiza informações remotas** (`git fetch --prune`)
4. **Identifica branches locais** que estão mergeados no branch principal configurado
5. **Exclui branches especiais** (branch principal, `HEAD`, e branch atual marcado com `*`)
6. **Verifica cada branch** duas vezes antes de remover
7. **Deleta branch local** (`git branch -d`)
8. **Deleta branch remoto** se existir (`git push origin --delete`)

## 🔍 Exemplo de Saída

**Execução após configuração:**

```
=== Iniciando limpeza de branches mergeados no origin/main ===

Fazendo checkout no main e atualizando...
Already on 'main'
Already up to date.

Atualizando informações remotas...

Verificando branches locais (excluindo main e HEAD)...

Branches locais mergeados no origin/main:
feature/login
feature/dashboard
feature/api-auth

Processando cada branch...

=== Branch: feature/login ===
✓ Confirmado: feature/login está mergeado em origin/main
  Deletando branch local: feature/login
  Deletando branch remoto: origin/feature/login

=== Branch: feature/dashboard ===
✓ Confirmado: feature/dashboard está mergeado em origin/main
  Deletando branch local: feature/dashboard
  Deletando branch remoto: origin/feature/dashboard

=== Branch: feature/api-auth ===
✓ Confirmado: feature/api-auth está mergeado em origin/main
  Deletando branch local: feature/api-auth
  Branch remoto origin/feature/api-auth não existe (ou já foi deletado)

=== Fim da limpeza de branches ===

=== Processo concluído ===
```

## ⚙️ Como funciona

O script utiliza os seguintes comandos Git:

- `git branch --merged <branch-principal>` - Lista branches mergeados
- `git merge-base --is-ancestor` - Verifica se um branch é ancestral do branch principal
- `git show-ref --verify` - Verifica se um branch existe
- `git branch -d` - Deleta branch local (safe delete)
- `git push origin --delete` - Deleta branch remoto

**Configuração:**
- Armazena o nome do branch principal em `~/.config/git-clean/settings.json`
- Lê a configuração automaticamente em cada execução subsequente

## 🛡️ Segurança

- **Dupla verificação**: Cada branch é verificado duas vezes antes de ser removido
- **Proteção de branches**: `main`, `HEAD` e o branch atual nunca são removidos
- **Safe delete**: Usa `git branch -d` em vez de `git branch -D` (que força a deleção)
- **Feedback completo**: Mostra tudo o que está sendo feito em tempo real

## 📌 Observações

- Na primeira execução, você precisará informar o nome do seu branch principal (ex: `main`, `master`, `production`)
- A configuração é salva em `~/.config/git-clean/settings.json` e reutilizada automaticamente
- Para alterar o branch principal configurado, edite o arquivo `~/.config/git-clean/settings.json` ou exclua-o e execute o script novamente
- Certifique-se de ter as permissões necessárias para deletar branches no repositório remoto
- O script sempre finaliza fazendo checkout no branch principal configurado e atualizando-o
- Branches remotos que não existem mais (mas ainda aparecem localmente) são tratados corretamente

## 📂 Arquivo de Configuração

O script cria automaticamente o arquivo `~/.config/git-clean/settings.json` na primeira execução:

```json
{
  "main_branch": "main"
}
```

Você pode editar manualmente este arquivo para alterar o branch principal configurado.

## 🔧 Personalização

**Alterar o branch principal configurado:**

1. **Opção 1 - Editar o arquivo de configuração:**
   ```bash
   nano ~/.config/git-clean/settings.json
   ```
   Altere o valor de `main_branch` para o desejado:
   ```json
   {
     "main_branch": "master"
   }
   ```

2. **Opção 2 - Reconfigurar:**
   ```bash
   rm ~/.config/git-clean/settings.json
   git-clean
   ```
   O script pedirá novamente o nome do branch principal através do prompt "Informe o nome do branch de produção:".

## 📄 Licença

Este projeto é de código aberto e está disponível para uso livre.

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.
