#!/bin/bash

# Script para remover branches locais e remotos que já estão mergeados no branch principal
# MUITO CUIDADOSO: Só remove branches que realmente estão mergeados

set -e

CONFIG_DIR="$HOME/.config/git-clean"
CONFIG_FILE="$CONFIG_DIR/settings.json"
MAIN_BRANCH=""

mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
	MAIN_BRANCH=$(grep -o '"main_branch"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed 's/.*"\([^"]*\)".*/\1/')
fi

if [ -z "$MAIN_BRANCH" ]; then
	echo "=== Configuração inicial ==="
	echo "Qual é o nome do branch de produção do seu projeto? (ex: main, master, production)"
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

# Atualizar informações remotas
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
echo "Fazendo checkout no $MAIN_BRANCH e atualizando..."
git checkout "$MAIN_BRANCH"
git pull

echo ""
echo "=== Processo concluído ==="
