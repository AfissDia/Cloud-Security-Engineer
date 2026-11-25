# Plan de tests et résultats - DataHelix

## Méthode
Un test n'est considéré comme **PASS observé** que lorsqu'un résultat a été effectivement partagé pendant le projet. Les cas non rejoués sont marqués **À valider**, y compris lorsque le code existe.

| ID | Contrôle | Scénario | Résultat disponible | Statut |
| --- | --- | --- | --- | --- |
| T01 | Comptes | Lister Management + cinq comptes membres | Six comptes trouvés après redémarrage | PASS observé |
| T02 | OU/SCP | Lire la politique et ses rattachements | SCP créée et attachée avant incident | PASS configuration |
| T03 | SCP logique | Tester un refus CloudTrail via règles IaC | `tests/test_scp.py` analyse la structure, pas le refus API | PARTIEL |
| T04 | Réseau | Lire VPC PROD, STAGING, DEV | VPC CIDR 10.10/16, 10.20/16, 10.30/16 créés avant incident | PASS avant incident |
| T05 | SG | Contrôler les règles entrantes et sortantes | Baseline et default SG configurés | PASS configuration |
| T06 | IAM | Lire rôle d'audit en DEV | `DataHelix-SecurityAudit` présent après incident | PASS configuration |
| T07 | IAM accès | `AssumeRole` depuis SECURITY puis `DescribeVpcs` | Pas de résultat de test partagé | À valider |
| T08 | Trail | Vérifier `IsLogging` | True avant incident ; trail perdu après redémarrage | PASS avant incident |
| T09 | Export | `lookup-events` puis `put-object` vers S3 | `lab-export/events.json`, 4 294 octets | PASS export manuel |
| T10 | SOC normal | Détecteur sur 3 événements observés | 0 alerte | PASS observé |
| T11 | SOC attaque | Détecteur sur 3 événements synthétiques | 3 alertes | PASS observé |
| T12 | Object Lock | Tenter de supprimer une version en GOVERNANCE | `AccessDenied` | PASS observé |
| T13 | Checkov | Analyse statique IaC | 69 PASS, 15 FAIL | PASS brut 82,1 % |
| T14 | Trivy | Analyse statique IaC | 286 PASS, 7 FAIL | PASS brut 97,6 % |
| T15 | Nouveau compte | Créer compte par module réutilisable | Module livré comme proposition, non exécuté | À valider |
| T16 | Déploiement global | Déployer avec orchestrateur | Script d'orchestration proposé, non exécuté | À valider |
| T17 | Persistance | Redémarrer brutalement Ubuntu | Perte partielle de ressources observée | FAIL |

## Scénarios fonctionnels cibles

### Contrôle SCP (non démontré en API)
- Prérequis : SCP appliquée à l'OU concernée.
- Tentative : supprimer le Trail ou quitter l'organisation avec un compte membre.
- Résultat attendu sur AWS réel : `AccessDenied` ou refus équivalent.
- Dans MiniStack : seule la logique déclarative a été analysée. Ne pas enregistrer PASS fonctionnel sans preuve.

### Contrôle IAM (non rejoué)
- Compte SECURITY : assumer un rôle DEV prévu pour l'audit.
- Session assumée : demander `DescribeVpcs`, `DescribeSubnets`, `DescribeSecurityGroups`.
- Test négatif : tentative d'une opération d'écriture EC2.
- Comparer le comportement MiniStack aux politiques documentées.

### Test du module de compte (non rejoué)
- Fournir un nom de compte, une adresse de contact et l'identifiant OU.
- Exécuter `tofu plan` puis `tofu apply` dans un environnement neuf.
- Vérifier création, rattachement à l'OU, SCP héritée et absence de droits additionnels.
- Documenter toute fonction MiniStack non prise en charge.

### Tests de détection observés
- `StopLogging` : DET-001, CRITICAL.
- `UpdatePolicy` : DET-002, HIGH.
- `DeletePublicAccessBlock` : DET-003, HIGH.

Les données de ces tests sont **synthétiques**. Leurs preuves sont dans `evidence/detection/` du dépôt local.

## Critères de réception
- Aucune affirmation de couverture fonctionnelle non démontrée.
- Conservation des fichiers de preuve et du code ayant produit le résultat.
- Écarts de scan documentés avec statut corrigé, risque accepté ou travaux futurs.
- Les objectifs académiques encore ouverts sont indiqués sans les masquer.
