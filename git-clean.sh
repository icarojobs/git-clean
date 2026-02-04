#!/bin/bash

# Script para remover branches locais e remotos que já estão mergeados no branch principal
# MUITO CUIDADOSO: Só remove branches que realmente estão mergeados

GITHUB_REPO="icarojobs/git-clean"
RAW_URL="https://raw.githubusercontent.com/$GITHUB_REPO/refs/heads/main/git-clean.sh"
LOCAL_SCRIPT=$(readlink -f "$0")

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
	echo "Git Clean - Script para limpeza de branches mergeados"
	echo ""
	echo "Uso: git-clean [opções]"
	echo ""
	echo "Opções:"
	echo "  --help, -h     Exibe esta mensagem de ajuda"
	echo "  --version, -v  Exibe a versão atual do script"
	echo "  --upgrade      Atualiza o script para a versão mais recente"
	echo ""
	echo "Exemplo:"
	echo "  git-clean              Executa a limpeza de branches mergeados"
	echo "  git-clean --help       Exibe esta mensagem de ajuda"
	echo "  git-clean --version    Exibe a versão atual"
	echo "  git-clean --upgrade    Atualiza o script"
	echo ""
	echo "Na primeira execução, você será solicitado a informar o nome do branch de produção."
	exit 0
fi

if [ "$1" = "--upgrade" ]; then
	echo "Atualizando git-clean..."
	if ! command -v curl &>/dev/null; then
		echo "Erro: curl não está instalado. Instale curl para atualizar o script."
		exit 1
	fi

	REMOTE_CONTENT=$(curl -s "$RAW_URL")
	if [ -z "$REMOTE_CONTENT" ]; then
		echo "Erro ao baixar o script. Verifique sua conexão com a internet."
		exit 1
	fi

	echo "$REMOTE_CONTENT" >"$LOCAL_SCRIPT"
	chmod +x "$LOCAL_SCRIPT"
	echo "Script atualizado com sucesso!"
	exit 0
fi

if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
	VERSION=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
	if [ -z "$VERSION" ]; then
		echo "Erro ao buscar a versão. Verifique sua conexão com a internet."
		exit 1
	fi
	echo "git-clean $VERSION"

	REMOTE_CONTENT=$(curl -s "$RAW_URL")
	if [ -n "$REMOTE_CONTENT" ] && command -v sha256sum &>/dev/null; then
		LOCAL_HASH=$(sha256sum "$LOCAL_SCRIPT" | cut -d' ' -f1)
		REMOTE_HASH=$(echo "$REMOTE_CONTENT" | sha256sum | cut -d' ' -f1)

		if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
			echo ""
			echo "O seu script git-clean está desatualizado."
			echo "Entre com o comando git-clean --upgrade para atualizar."
		fi
	fi
	exit 0
fi

set -e

CONFIG_DIR="$HOME/.config/git-clean"
CONFIG_FILE="$CONFIG_DIR/settings.json"
MAIN_BRANCH=""

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ] && [ -s "$CONFIG_FILE" ]; then
	MAIN_BRANCH=$(cat "$CONFIG_FILE" | sed -n 's/.*"main_branch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi

if [ -z "$MAIN_BRANCH" ]; then
	echo "=== Configuração inicial ==="
	echo "Informe o nome do branch de produção:"
	read -p "> " MAIN_BRANCH

	if [ -z "$MAIN_BRANCH" ]; then
		echo "Erro: Nome do branch não pode ser vazio."
		exit 1
	fi

	echo "{\"main_branch\": \"$MAIN_BRANCH\"}" >"$CONFIG_FILE"
	echo ""
	echo "Configuração salva em: $CONFIG_FILE"
	echo ""
fi

MAIN_REMOTE="origin/$MAIN_BRANCH"

echo "=== Iniciando limpeza de branches mergeados no $MAIN_REMOTE ==="
echo ""

echo "Fazendo checkout no $MAIN_BRANCH e atualizando..."
git checkout "$MAIN_BRANCH"
git pull

echo ""
echo "Atualizando informações remotas..."
git fetch --prune

echo ""
echo "Verificando branches locais (excluindo $MAIN_BRANCH e HEAD)..."
echo ""

# Encontrar branches locais (excluindo main e HEAD) que estão mergeados no origin/main
MERGED_BRANCHES=$(git branch --merged "$MAIN_REMOTE" | grep -v "^\*" | grep -v "$MAIN_BRANCH" | grep -v "HEAD" | sed 's/^[ \t]*//' || true)

if [ -z "$MERGED_BRANCHES" ]; then
	echo "Nenhum branch local encontrado que esteja mergeado no $MAIN_REMOTE."
else
	echo "Branches locais mergeados no $MAIN_REMOTE:"
	echo "$MERGED_BRANCHES"
	echo ""
	echo "Processando cada branch..."
	echo ""

	for branch in $MERGED_BRANCHES; do
		echo "=== Branch: $branch ==="

		# Verificar novamente se está realmente mergeado (dupla verificação)
		if git merge-base --is-ancestor "$branch" "$MAIN_REMOTE" 2>/dev/null; then
			echo "✓ Confirmado: $branch está mergeado em $MAIN_REMOTE"

			# Deletar branch local
			if git show-ref --verify --quiet "refs/heads/$branch"; then
				echo "  Deletando branch local: $branch"
				git branch -d "$branch"
			fi

			# Verificar se existe branch remoto correspondente e deletar
			if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
				echo "  Deletando branch remoto: origin/$branch"
				git push origin --delete "$branch"
			else
				echo "  Branch remoto origin/$branch não existe (ou já foi deletado)"
			fi
		else
			echo "✗ $branch NÃO está mergeado em $MAIN_REMOTE (não será removido)"
		fi
		echo ""
	done
fi

echo "=== Fim da limpeza de branches ==="

echo ""
echo "=== Processo concluído ==="
