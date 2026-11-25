# Limites MiniStack - Projet DataHelix

## Environnement
- Ubuntu 22.04
- MiniStack 1.5.40
- OpenTofu
- AWS CLI

## Persistance

La persistance a été configurée avec :
- PERSIST_STATE=1
- S3_PERSIST=1
- STATE_DIR
- S3_DATA_DIR

Les comptes AWS simulés, IAM et le bucket S3 ont été conservés.

Après un redémarrage inattendu, certaines ressources
CloudTrail, EC2/VPC et la configuration Object Lock
n'étaient plus présentes.

Les fichiers d'état OpenTofu sont restés disponibles.

## Tests réalisés avant le redémarrage

- Six comptes AWS simulés créés.
- SCP déployée.
- Rôle IAM inter-comptes créé.
- CloudTrail organisationnel actif.
- Trois VPC déployés.
- Export manuel des événements CloudTrail vers S3.
- Trois règles SOC validées avec des événements synthétiques.
- Test Object Lock : suppression refusée.
- Checkov : 69 PASS / 15 FAIL - 82,1 % brut.
- Trivy : 286 PASS / 7 FAIL - 97,6 % brut.

## Limites

- La persistance complète de MiniStack n'a pas été démontrée.
- La livraison native CloudTrail vers S3 n'a pas été validée.
- Les règles SOC ont été testées avec des événements synthétiques.
- L'application complète des contrôles IAM/SCP reste à vérifier.
- Les résultats du laboratoire ne garantissent pas un comportement
  identique sur AWS réel.

## Recommandations

- Conserver les fichiers IaC et les preuves.
- Vérifier les ressources avant chaque démonstration.
- Ne pas réutiliser aveuglément un ancien état OpenTofu.
- Documenter les limites de l'émulateur.
