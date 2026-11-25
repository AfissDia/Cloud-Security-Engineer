# Limites MiniStack - DataHelix

## Contexte

Le laboratoire utilise MiniStack 1.5.40 avec OpenTofu et AWS CLI sur Ubuntu 22.04. Les commandes AWS CLI doivent cibler `http://127.0.0.1:4566`.

## Persistance observée

- `PERSIST_STATE=1`, `S3_PERSIST=1`, `STATE_DIR` et `S3_DATA_DIR` ont été configurés.
- Après un arrêt contrôlé, les comptes Organizations, IAM et le bucket S3 avaient été retrouvés.
- Après un redémarrage imprévu d'Ubuntu, les six comptes, le rôle IAM et le bucket existaient, mais le Trail, les VPC et la configuration Object Lock n'étaient plus présents.
- Les fichiers persistants `organizations.json`, `iam.json` et `s3.json` conservaient une date du 21 novembre 2026. Aucun `cloudtrail.json` ni `ec2.json` n'était visible dans le dossier de persistance consulté.
- Les fichiers locaux `terraform.tfstate` ont été conservés, mais ils décrivent des ressources qui peuvent ne plus exister. Ne pas relancer `tofu apply` aveuglément après cet incident.

## Autres limites techniques

- La livraison native des événements CloudTrail vers S3 n'a pas été démontrée. Les événements ont été récupérés par `lookup-events` et exportés manuellement.
- Des événements API ont été observés pour le compte de management; la couverture effective de tous les comptes n'est pas prouvée.
- Les tests de règles SOC sensibles ont utilisé trois événements synthétiques.
- Les contrôles SCP et IAM sont déclarés dans le code mais leur application complète par l'émulateur n'est pas démontrée.
- Le test Object Lock en mode GOVERNANCE a refusé une suppression sans contournement sur une version de test. Ce résultat n'implique pas une protection absolue.
- Les paramètres de chiffrement S3 et les règles Security Group ont été lus par API, mais cela ne remplace pas un test de chiffrement local ou de trafic réseau réel.

## Bonne pratique retenue

Conserver le code IaC, les états privés et les preuves; tester séparément chaque comportement; documenter explicitement les limites. Avant une soutenance, vérifier l'état de MiniStack et utiliser les preuves enregistrées si certains services ont disparu.
