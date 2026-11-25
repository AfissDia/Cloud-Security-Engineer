#!/usr/bin/env bash
set -Eeuo pipefail

# Orchestrateur prudent pour les 5 stacks existants.
# Usage : bash scripts/deploy-all.sh plan
#         bash scripts/deploy-all.sh apply
# L'application nécessite une approbation explicite et un environnement coherent.

MODE="${1:-plan}"
case "$MODE" in plan|apply|validate) ;; *) echo "Usage: $0 [validate|plan|apply]" >&2; exit 2;; esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENDPOINT="${DATAHELIX_ENDPOINT:-http://127.0.0.1:4566}"
: "${DATAHELIX_MGMT_ID:?Définir DATAHELIX_MGMT_ID}"
: "${DATAHELIX_DEV_ID:?Définir DATAHELIX_DEV_ID}"
: "${DATAHELIX_LOG_ID:?Définir DATAHELIX_LOG_ID}"
: "${DATAHELIX_PROD_ID:?Définir DATAHELIX_PROD_ID}"
: "${DATAHELIX_STAGING_ID:?Définir DATAHELIX_STAGING_ID}"

for id in "$DATAHELIX_MGMT_ID" "$DATAHELIX_DEV_ID" "$DATAHELIX_LOG_ID" "$DATAHELIX_PROD_ID" "$DATAHELIX_STAGING_ID"; do
  [[ "$id" =~ ^[0-9]{12}$ ]] || { echo "Compte non valide : $id" >&2; exit 1; }
done

command -v tofu >/dev/null || { echo 'OpenTofu absent' >&2; exit 1; }
command -v aws >/dev/null || { echo 'AWS CLI absent' >&2; exit 1; }

if [[ "$MODE" != validate ]]; then
  [[ "$ENDPOINT" == "http://127.0.0.1:4566" || "$ENDPOINT" == "http://localhost:4566" ]] || {
    echo "Endpoint local attendu; refus de contacter une API externe" >&2; exit 1;
  }
  export AWS_ACCESS_KEY_ID="$DATAHELIX_MGMT_ID" AWS_SECRET_ACCESS_KEY=test
  export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-eu-west-3}" AWS_EC2_METADATA_DISABLED=true
  AWS_PAGER='' aws --endpoint-url="$ENDPOINT" sts get-caller-identity >/dev/null
fi

# Ne pas utiliser ce script pour réparer un état corrompu : un plan destructif
# doit être analysé manuellement, module par module.
if [[ "$MODE" == apply ]]; then
  echo 'ATTENTION : chaque plan doit avoir été vérifié. Ne pas utiliser sur les états perdus de MiniStack.'
  [[ "${DATAHELIX_ALLOW_APPLY:-}" == 'I_HAVE_REVIEWED_ALL_PLANS' ]] || {
    echo 'Refus : définir DATAHELIX_ALLOW_APPLY=I_HAVE_REVIEWED_ALL_PLANS après revue.' >&2
    exit 1
  }
fi

run_stack() {
  local stack="$1" account="$2" dir="$ROOT/infra/$stack"
  [[ -d "$dir" ]] || { echo "Stack manquant : $dir" >&2; exit 1; }
  echo "=== $stack / $account / $MODE ==="
  export AWS_ACCESS_KEY_ID="$account" AWS_SECRET_ACCESS_KEY=test
  ( cd "$dir"
    tofu init -lockfile=readonly -input=false
    tofu validate
    if [[ "$MODE" == plan ]]; then
      tofu plan -input=false -out="/tmp/datahelix-${stack}-$$.tfplan"
      rm -f "/tmp/datahelix-${stack}-$$.tfplan"
    elif [[ "$MODE" == apply ]]; then
      tofu plan -input=false -out="/tmp/datahelix-${stack}-$$.tfplan"
      echo "Examiner attentivement le plan ci-dessus. Appliquer ? Tapez APPLIQUER :"
      read -r response
      [[ "$response" == APPLIQUER ]] || { echo 'Arrêt demandé'; exit 1; }
      tofu apply -input=false "/tmp/datahelix-${stack}-$$.tfplan"
      rm -f "/tmp/datahelix-${stack}-$$.tfplan"
    fi
  )
}

# Attention : dépendances d'ARN et d'IDs entre modules.
# Les variables/root_id/providers doivent être synchronisés avec l'environnement neuf.
run_stack organizations "$DATAHELIX_MGMT_ID"
run_stack iam-dev "$DATAHELIX_DEV_ID"
run_stack log-archive "$DATAHELIX_LOG_ID"
run_stack cloudtrail "$DATAHELIX_MGMT_ID"
# Le module network gère ses trois providers alias; la variable d'account par défaut
# n'établit pas leur identité. Vérifier leurs paramètres avant exécution.
run_stack network "$DATAHELIX_MGMT_ID"
echo 'Terminé. Vérifier les comptes, les VPC, le trail et les protections S3.'
