# PROCEDURE - Reproduire DataHelix en une journée

Cette procédure reprend **le projet existant** (ses fichiers `.tf`, ses scripts et ses tests). Elle n'est pas un générateur d'infrastructure à partir d'un répertoire vide.

Objectif : déployer le laboratoire, vérifier les composants et conserver des preuves **en une journée** si Ubuntu, le dépôt et les dépendances sont disponibles. MiniStack est un émulateur : tous les services ne reproduisent pas AWS réel et certains états ne survivent pas à un redémarrage brutal.

## 0. Plan de la journée

| Période indicative | Travail |
| --- | --- |
| Matin 1 | Vérification de l'ordinateur, du dépôt et du démarrage MiniStack |
| Matin 2 | Organizations, IAM, S3 et CloudTrail |
| Après-midi 1 | VPC, collecte de logs et trois tests de détection |
| Après-midi 2 | Object Lock, Checkov, Trivy, preuves et sauvegardes |

Ne pas poursuivre une commande en erreur. **Ne jamais lancer `tofu destroy` pour réparer une perte de persistance.**

## 1. Préparer Ubuntu

Ouvrir deux terminaux : le premier pour MiniStack, le second pour AWS CLI/OpenTofu.

```bash
cd ~/projet7-datahelix

df -h /
python3 --version
tofu version
aws --version
```

Prévoir plusieurs Go libres. Ne pas utiliser `docker system prune --volumes` : les autres laboratoires peuvent dépendre de volumes Docker.

La structure attendue comprend `infra/organizations`, `infra/iam-dev`, `infra/log-archive`, `infra/cloudtrail`, `infra/network`, `scripts/detect_cloudtrail.py` et `tests/`.

Pour limiter les téléchargements répétés du fournisseur AWS OpenTofu :

```bash
mkdir -p "$HOME/.cache/tofu-providers"
export TF_PLUGIN_CACHE_DIR="$HOME/.cache/tofu-providers"
```

Attention : chaque dossier `.terraform` est régénérable par `tofu init`, mais **les fichiers `terraform.tfstate`, `.tf`, `.terraform.lock.hcl` ne sont pas des caches**.

## 2. Démarrer MiniStack en mode persistant

Terminal 1 :

```bash
cd ~/projet7-datahelix
source .venv/bin/activate
mkdir -p ministack-data/state ministack-data/s3
export PERSIST_STATE=1
export S3_PERSIST=1
export STATE_DIR="$PWD/ministack-data/state"
export S3_DATA_DIR="$PWD/ministack-data/s3"
ministack
```

Laisser ce terminal ouvert. Ne pas démarrer une deuxième instance si le port 4566 est déjà utilisé.

Terminal 2 :

```bash
cd ~/projet7-datahelix
export AWS_ACCESS_KEY_ID=111111111111
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=eu-west-3
export AWS_EC2_METADATA_DISABLED=true
export ENDPOINT=http://127.0.0.1:4566

aws --endpoint-url="$ENDPOINT" sts get-caller-identity
```

Pour vérifier la disponibilité, préférer la commande STS ci-dessus. La réponse de `/_ministack/health` n'est pas toujours un JSON exploitable : ne pas prendre un échec de `python3 -m json.tool` comme une preuve de perte de l'infrastructure.

**Important :** toujours préciser l'endpoint pour AWS CLI. Pour OpenTofu, vérifier que chaque `providers.tf` renseigne l'endpoint du service utilisé (Organizations, IAM, S3, STS, EC2, CloudTrail). Sinon les fausses clés risquent d'être envoyées à AWS réel.

## 3. Prévenir les erreurs de compte et d'état

Avant **chaque** module, contrôler le compte actif :

```bash
aws --endpoint-url="$ENDPOINT" sts get-caller-identity --query Account --output text
```

Ne jamais réutiliser aveuglément les états d'une organisation MiniStack précédente : ils peuvent référencer des ressources absentes ou des identifiants périmés.

- Pour un laboratoire **déjà déployé**, conserver les états et commencer par les commandes de lecture AWS CLI.
- Pour un laboratoire **entièrement neuf**, archiver les anciens états avant une nouvelle création, et vérifier qu'aucune ressource équivalente n'existe déjà.
- Si l'émulateur perd seulement CloudTrail ou EC2, ne pas recréer toute l'organisation. Conserver les preuves et documenter la limite. La reprise d'un état partiellement perdu doit être traitée séparément, pas par un `apply` aveugle.

Sauvegarde privée avant de modifier les états :

```bash
mkdir -p "$HOME/datahelix-final-backup"
tar -czf "$HOME/datahelix-final-backup/etats-prives-avant-actions.tar.gz" \
  infra/*/terraform.tfstate ministack-data
```

Ne pas publier les états sur GitHub.

## 4. Déployer Organizations

**Compte cible : Management `111111111111`.**

```bash
export AWS_ACCESS_KEY_ID=111111111111
export AWS_SECRET_ACCESS_KEY=test
cd ~/projet7-datahelix/infra/organizations
```

Si l'organisation est neuve, vérifier d'abord sa racine :

```bash
aws --endpoint-url="$ENDPOINT" organizations list-roots \
  --query 'Roots[*].[Id,Name]' --output table
```

Comparer ce root ID avec la variable `root_id` du module `infra/organizations`. Les identifiants peuvent changer après reconstruction. Corriger la variable **dans le code** avant le plan.

```bash
tofu init -lockfile=readonly
tofu fmt
tofu validate
tofu plan
# Appliquer seulement si le plan crée les ressources attendues,
# sans suppression ni remplacement non prévu.
tofu apply

tofu output
aws --endpoint-url="$ENDPOINT" organizations list-accounts \
  --query 'Accounts[*].[Name,Id,Status]' --output table
```

Résultat cible : Management, PROD, STAGING, DEV, SECURITY et LOG-ARCHIVE. Conserver les nouveaux identifiants. Dans le laboratoire historique, les cinq comptes sont : PROD `431122467493`, STAGING `627415924341`, DEV `153921435903`, SECURITY `616337743862`, LOG-ARCHIVE `888031631734`.

Le module actuel et certains providers peuvent comporter des identifiants en dur : **les mettre à jour avant les étapes suivantes** si la nouvelle création en a généré d'autres.

## 5. Déployer IAM dans DEV

La trust policy `DataHelix-SecurityAudit` doit référencer le compte SECURITY actuel. Contrôler `infra/iam-dev/main.tf`.

```bash
export AWS_ACCESS_KEY_ID=153921435903   # remplacer si le compte DEV a changé
export AWS_SECRET_ACCESS_KEY=test
cd ~/projet7-datahelix/infra/iam-dev

tofu init -lockfile=readonly
tofu validate
tofu plan
# Confirmer que les actions prévues sont bien celles du rôle d'audit.
tofu apply

aws --endpoint-url="$ENDPOINT" iam get-role \
  --role-name DataHelix-SecurityAudit
aws --endpoint-url="$ENDPOINT" iam get-role-policy \
  --role-name DataHelix-SecurityAudit \
  --policy-name DataHelix-NetworkAudit
```

Le rôle est destiné à la consultation des VPC, subnets, Security Groups et tables de routage. Le fait que le rôle existe ne prouve pas que MiniStack applique intégralement les autorisations.

## 6. Déployer LOG-ARCHIVE dans son compte

Contrôler le nom du bucket dans `infra/log-archive/main.tf`. Pour notre exécution : `datahelix-log-archive-888031631734`.

```bash
export AWS_ACCESS_KEY_ID=888031631734  # remplacer si nécessaire
export AWS_SECRET_ACCESS_KEY=test
cd ~/projet7-datahelix/infra/log-archive

tofu init -lockfile=readonly
tofu validate
tofu plan
# Ne pas appliquer si le bucket existant doit être remplacé.
tofu apply

export BUCKET=datahelix-log-archive-888031631734
aws --endpoint-url="$ENDPOINT" s3api get-bucket-versioning --bucket "$BUCKET"
aws --endpoint-url="$ENDPOINT" s3api get-bucket-encryption --bucket "$BUCKET"
aws --endpoint-url="$ENDPOINT" s3api get-public-access-block --bucket "$BUCKET"
aws --endpoint-url="$ENDPOINT" s3api get-bucket-policy --bucket "$BUCKET" --query Policy --output text
```

Résultats attendus : versioning `Enabled`, chiffrement déclaré `AES256`, quatre options de blocage public actives, politique autorisant CloudTrail. `BucketKeyEnabled: false` est normal pour SSE-S3 : cela ne veut pas dire que la configuration de chiffrement est désactivée.

**Attention aux dépendances :** la politique CloudTrail contient un ARN de Trail et un identifiant d'organisation. Mettre ces valeurs en cohérence avec la nouvelle exécution si elles ont changé.

## 7. Déployer CloudTrail depuis Management

```bash
export AWS_ACCESS_KEY_ID=111111111111
export AWS_SECRET_ACCESS_KEY=test
cd ~/projet7-datahelix/infra/cloudtrail
```

Dans `providers.tf`, l'endpoint CloudTrail doit être présent :

```hcl
endpoints {
  cloudtrail = "http://127.0.0.1:4566"
  # conserver les autres endpoints déjà définis
}
```

Ne pas créer un second bloc `endpoints` : ajouter la ligne dans le bloc existant.

```bash
tofu init -lockfile=readonly
tofu validate
tofu plan
tofu apply

aws --endpoint-url="$ENDPOINT" cloudtrail describe-trails \
  --trail-name-list DataHelix-Organization-Trail
aws --endpoint-url="$ENDPOINT" cloudtrail get-trail-status \
  --name DataHelix-Organization-Trail
```

On recherche `IsLogging: true`. Cela confirme la configuration du Trail dans MiniStack, pas la livraison automatique des fichiers dans S3.

## 8. Déployer les trois VPC

`infra/network/providers.tf` utilise trois alias de provider correspondant aux comptes PROD, STAGING et DEV. Si leurs IDs ont changé, modifier les identifiants fictifs du fichier avant le plan.

```bash
cd ~/projet7-datahelix/infra/network
tofu init -lockfile=readonly
tofu fmt -recursive
tofu validate
tofu plan
# Sur une création initiale avec les groupes par défaut gérés,
# le plan peut comporter 12 ressources, pas seulement 9.
tofu apply
tofu output
```

Vérifier les trois CIDR attendus :

```bash
for item in 'PROD:431122467493' 'STAGING:627415924341' 'DEV:153921435903'; do
  NAME=${item%%:*}; ID=${item##*:}
  echo "=== $NAME ==="
  AWS_ACCESS_KEY_ID="$ID" AWS_SECRET_ACCESS_KEY=test \
    aws --endpoint-url="$ENDPOINT" ec2 describe-vpcs \
    --query 'Vpcs[*].[VpcId,CidrBlock]' --output table
done
```

VPC attendus : PROD `10.10.0.0/16`, STAGING `10.20.0.0/16`, DEV `10.30.0.0/16`. Un VPC `172.31.0.0/16` peut aussi être présent par défaut : ne pas le confondre avec celui du projet.

Pour le Security Group par défaut, vérifier **par son ID** : une recherche par `group-name=default` a fourni des résultats contradictoires pendant le projet.

## 9. Collecter des événements et exporter les logs

MiniStack possède un paramètre d'enregistrement interne distinct du statut du Trail :

```bash
curl -sS -X POST "$ENDPOINT/_ministack/config" \
  -H 'Content-Type: application/json' \
  -d '{"cloudtrail._recording_enabled":true}'

export AWS_ACCESS_KEY_ID=111111111111
export AWS_SECRET_ACCESS_KEY=test
aws --endpoint-url="$ENDPOINT" sts get-caller-identity
aws --endpoint-url="$ENDPOINT" organizations list-accounts
aws --endpoint-url="$ENDPOINT" s3api list-buckets

mkdir -p ~/projet7-datahelix/evidence/cloudtrail
cd ~/projet7-datahelix
aws --endpoint-url="$ENDPOINT" cloudtrail lookup-events --output json \
  > evidence/cloudtrail/events.json
python3 -m json.tool evidence/cloudtrail/events.json >/dev/null
```

Exporter manuellement vers S3, dans un préfixe clairement distinct des livraisons natives :

```bash
AWS_ACCESS_KEY_ID=888031631734 AWS_SECRET_ACCESS_KEY=test \
aws --endpoint-url="$ENDPOINT" s3api put-object \
  --bucket "$BUCKET" --key lab-export/events.json \
  --body evidence/cloudtrail/events.json --content-type application/json

AWS_ACCESS_KEY_ID=888031631734 AWS_SECRET_ACCESS_KEY=test \
aws --endpoint-url="$ENDPOINT" s3api list-objects-v2 \
  --bucket "$BUCKET" --prefix lab-export/ \
  --query 'Contents[*].[Key,Size]' --output table
```

Cette opération est **manuelle**. Ne pas la présenter comme une livraison native CloudTrail multi-comptes.

## 10. Tester la détection SOC

```bash
cd ~/projet7-datahelix
mkdir -p evidence/detection

# Événements enregistrés dans MiniStack
python3 scripts/detect_cloudtrail.py evidence/cloudtrail/events.json

# Enregistrer les résultats avant le deuxième test
cp evidence/detection/alerts.json evidence/detection/alerts_normal_test.json

# Trois scénarios synthétiques, sans modifier les protections AWS
python3 scripts/detect_cloudtrail.py tests/fixtures/cloudtrail_attack_events.json
cp evidence/detection/alerts.json evidence/detection/alerts_attack_test.json
```

Résultats historiques : 3 événements ordinaires -> 0 alerte, puis 3 événements synthétiques (`StopLogging`, `UpdatePolicy`, `DeletePublicAccessBlock`) -> 3 alertes. La fixture et les sorties doivent être étiquetées **synthétiques**.

## 11. Tester Object Lock sur un objet sans importance

Depuis LOG-ARCHIVE, vérifier la configuration après le déploiement :

```bash
export AWS_ACCESS_KEY_ID=888031631734
export AWS_SECRET_ACCESS_KEY=test
aws --endpoint-url="$ENDPOINT" s3api get-object-lock-configuration --bucket "$BUCKET"
```

Si le résultat contient `ObjectLockEnabled: Enabled` et `GOVERNANCE` sur 7 jours, tester **un nouvel objet temporaire**, jamais les vrais journaux :

```bash
cd ~/projet7-datahelix
mkdir -p evidence/object-lock
printf 'Test DataHelix - Object Lock\n' > evidence/object-lock/test-protection.txt
export KEY="security-tests/test-protection-$(date +%s).txt"

VERSION_ID=$(aws --endpoint-url="$ENDPOINT" s3api put-object \
  --bucket "$BUCKET" --key "$KEY" \
  --body evidence/object-lock/test-protection.txt \
  --query VersionId --output text)

echo "Version testée : $VERSION_ID"
aws --endpoint-url="$ENDPOINT" s3api get-object-retention \
  --bucket "$BUCKET" --key "$KEY" --version-id "$VERSION_ID"

# Une erreur AccessDenied est attendue si la rétention est appliquée.
aws --endpoint-url="$ENDPOINT" s3api delete-object \
  --bucket "$BUCKET" --key "$KEY" --version-id "$VERSION_ID"
```

**Ne pas utiliser `--bypass-governance-retention`.** Si l'appel de suppression réussit, ne pas déclarer le contrôle validé.

## 12. Scanner les configurations IaC

Checkov et Trivy ne modifient pas les ressources AWS simulées.

```bash
cd ~/projet7-datahelix
source .venv-checkov/bin/activate
mkdir -p evidence/security-scans

checkov -d infra --framework terraform --output json \
  > evidence/security-scans/checkov-final.json

trivy config infra --format json \
  --output evidence/security-scans/trivy-final.json
```

Un scanner peut renvoyer un code de sortie non nul en présence de contrôles échoués : consulter le rapport plutôt que le relancer à répétition.

Résultats historiques : Checkov 69 PASS / 15 FAIL = 82,1 % brut, Trivy 286 PASS / 7 FAIL = 97,6 % brut. Ces chiffres sont à **recalculer** après toute modification IaC. Voir `SECURITY-REPORT.md` pour les écarts.

## 13. Sauvegarder et protéger le dépôt

```bash
cd ~/projet7-datahelix
mkdir -p "$HOME/datahelix-final-backup"

tar -czf "$HOME/datahelix-final-backup/datahelix-code-preuves.tar.gz" \
  --exclude='.terraform' --exclude='.venv' \
  --exclude='.venv-checkov' --exclude='terraform.tfstate' \
  --exclude='terraform.tfstate.backup' --exclude='ministack-data' \
  infra scripts tests evidence docs README.md \
  PROCEDURE.md ARCHITECTURE.md SECURITY-REPORT.md

tar -czf "$HOME/datahelix-final-backup/datahelix-etats-prives.tar.gz" \
  infra/*/terraform.tfstate ministack-data

tar -tzf "$HOME/datahelix-final-backup/datahelix-code-preuves.tar.gz" | head
```

Ajouter au `.gitignore` les chemins sensibles :

```gitignore
.venv/
.venv-checkov/
**/.terraform/
**/terraform.tfstate
**/terraform.tfstate.backup
ministack-data/
*.tfplan
```

Vérifier avec `git status` **avant** de publier. Les données persistantes et les états doivent rester privés.

## 14. Dépannage express

| Symptôme | Cause probable | Réaction |
| --- | --- | --- |
| `NoRegion` | Région non définie | `export AWS_DEFAULT_REGION=eu-west-3` |
| `UnrecognizedClientException` sur CloudTrail | Endpoint CloudTrail manquant | Vérifier `cloudtrail = "http://127.0.0.1:4566"` dans le provider |
| `AccessDenied` sur S3 avec OpenTofu | Mauvais compte actif | Passer à LOG-ARCHIVE et contrôler `sts get-caller-identity` |
| `No changes` avec `-refresh=false` après un incident | État non vérifié auprès de MiniStack | Ne pas conclure que les ressources existent |
| Bucket absent des résultats | Mauvais compte actif ou perte d'état | Vérifier d'abord le compte et l'API S3 |
| Trail ou VPC introuvable après reboot | Persistance partielle observée | Conserver les preuves, éviter tout apply aveugle |
| `BucketKeyEnabled: false` | SSE-S3 et non SSE-KMS | Ce champ ne signifie pas que `AES256` est désactivé |
| Ubuntu saturé | Copies de providers `.terraform` | Diagnostiquer avec `du` et `df`, ne supprimer que les caches vérifiés |
| Deux commandes donnent des règles SG différentes | Filtrage ambigu | Vérifier par ID de Security Group |

## 15. Règle finale pour les démonstrations

- Avant une démo, vérifier les six comptes puis la présence du Trail, du bucket et des VPC.
- Si un service a perdu son état, **ne pas masquer le problème**. Montrer le code IaC et les preuves enregistrées, puis expliquer les limites.
- Ne pas promettre que MiniStack persistera automatiquement tous les services après un redémarrage brutal.
- Après une séance réussie, arrêter MiniStack proprement et sauvegarder les fichiers avant l'arrêt du PC.

La reconstruction complète en une journée est un **objectif de travail**, non une garantie liée à l'émulateur et à ses limites.
