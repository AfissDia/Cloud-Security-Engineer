# Rapport de sécurité - DataHelix

**Périmètre du rapport :** laboratoire AWS simulé avec MiniStack. Les résultats cités sont les observations réalisées pendant le projet et ne constituent ni une certification SOC 2 ni une validation sur AWS réel. Un redémarrage ultérieur a entraîné une perte partielle de ressources simulées. Les preuves et limitations sont documentées séparément.


## 1. Périmètre

Audit de la Landing Zone AWS simulée avec MiniStack, OpenTofu et cinq modules IaC : Organizations, IAM DEV, LOG-ARCHIVE, CloudTrail et Network.

Les résultats sont issus d'une exécution du laboratoire avant un redémarrage inattendu d'Ubuntu. Les fichiers `.tf` et les rapports ont été conservés, mais tous les états de MiniStack n'ont pas persisté.

## 2. Résultats des scanners

| Outil | PASS | FAIL | SKIPPED | Taux brut |
| --- | ---: | ---: | ---: | ---: |
| Checkov 3.4.7 | 69 | 15 | 0 | 82,1 % |
| Trivy 0.76.2 | 286 | 7 | Non relevé | 97,6 % |

Formule : PASS / (PASS + FAIL) x 100. Les taux dépassent 80 %, mais sont **bruts**. Les différences entre scanners et les contrôles non applicables à MiniStack doivent être expliqués; ces résultats ne garantissent pas une conformité SOC 2.

## 3. Écarts Trivy observés

| ID | Gravité | Écart | Traitement |
| --- | --- | --- | --- |
| AWS-0015 | HIGH | CloudTrail sans clé KMS gérée par le client | Risque résiduel, non corrigé dans ce laboratoire |
| AWS-0162 | LOW | Absence d'envoi CloudTrail vers CloudWatch Logs | Limitation de la chaîne locale, à étudier pour AWS réel |
| AWS-0089 | LOW | Absence de logs d'accès au bucket S3 | Mesure complémentaire non déployée |
| AWS-0132 | HIGH | Bucket SSE-S3 plutôt que SSE-KMS CMK | Chiffrement déclaré AES256, exigence CMK non satisfaite |
| AWS-0178 x3 | MEDIUM | VPC Flow Logs absents pour PROD/STAGING/DEV | Non déployés, absence de test de trafic réel |

## 4. Écarts Checkov observés après correction réseau

Le scan initial avait 66 PASS et 18 FAIL. L'ajout de `aws_default_security_group.restricted` dans le module VPC a fait passer les trois occurrences `CKV2_AWS_12` à PASS. Le dernier bilan observé : 69 PASS et 15 FAIL.

Principaux écarts restants du scan initial à examiner dans `evidence/security-scans/checkov-final.json` :

- `CKV_AWS_35` - pas de CMK sur CloudTrail.
- `CKV_AWS_252` - absence de SNS Topic CloudTrail.
- `CKV_AWS_61` - relation de confiance IAM insuffisamment précise selon le scanner.
- `CKV2_AWS_10` - CloudTrail non intégré à CloudWatch Logs.
- `CKV2_AWS_11` x3 - VPC Flow Logs absents.
- `CKV_AWS_144` - réplication S3 interrégion absente.
- `CKV2_AWS_5` x3 - Security Groups sans ressource attachée dans le laboratoire.
- `CKV2_AWS_61` - absence de politique S3 Lifecycle.
- `CKV2_AWS_62` - notifications d'événements S3 absentes.
- `CKV_AWS_18` - access logging S3 absent.
- `CKV_AWS_145` - SSE-S3 au lieu de SSE-KMS.

Ne pas créer de ressources artificielles uniquement pour faire monter un score. Chaque correction doit avoir un intérêt de sécurité et être compatible avec le périmètre.

## 5. Contrôles testés et limites

| Contrôle | Résultat effectivement observé | Limite |
| --- | --- | --- |
| Organizations | Six comptes membres et de management visibles | Simulation locale |
| SCP | Politique créée et attachée; analyse de la politique réalisée | Refus d'action réellement imposé non démontré |
| IAM | Rôle d'audit DEV présent | Application complète du trust et des permissions non démontrée |
| VPC | Trois VPC et subnets créés; SG restrictifs configurés | Pas de test de flux réseau réels |
| CloudTrail | Trail créé et déclaré actif; appels API visibles avec `lookup-events` | Couverture effective de tous les comptes non prouvée |
| S3 | Versioning, SSE-S3 et blocage public déclarés; objet exporté | Chiffrement physique local non prouvé |
| Archivage | Export manuel vers `lab-export/events.json` | Pas de livraison CloudTrail native |
| Détection | Trois alertes sur trois événements synthétiques | Pas de scénario d'attaque complet dans MiniStack |
| Object Lock | Rétention GOVERNANCE et suppression de version refusée | Test sans bypass; seulement sur la version testée |
| Persistance | Accounts/IAM/bucket conservés | EC2, Trail et Object Lock perdus après reboot brutal |

## 6. Analyse des risques - correspondances avec SOC 2

SOC 2 est un cadre d'évaluation des contrôles d'une organisation, pas une certification attribuée à ce laboratoire. Les thèmes ci-dessous sont une **mise en perspective pédagogique** des critères de services de confiance, principalement la sécurité et la disponibilité.

| Risque | Impact | Mesure observée / prévue | Risque restant |
| --- | --- | --- | --- |
| Compromission ou mauvaise configuration entre comptes | Élevé | Séparation par comptes, OU, SCP, rôles d'audit | Politique non testée en conditions AWS réelles |
| Suppression des preuves | Élevé | Versioning et Object Lock GOVERNANCE | Bypass possible, rétention non démontrée sur les anciens objets |
| Perte de visibilité sur les opérations | Élevé | Trail organisationnel et collecte `lookup-events` | Pas d'export natif ni de visibilité multi-comptes prouvée |
| Trafic réseau non maîtrisé | Moyen | VPC séparés, SG baseline restrictifs | Pas de VPC Flow Logs ni test effectif de trafic |
| Journalisation insuffisamment protégée | Moyen | Bucket S3 privé, SSE-S3, politique de service | Pas de CMK, access logging, réplication multi-région |
| Indisponibilité du laboratoire | Élevé pour la démonstration | IaC et sauvegarde des preuves | Persistance MiniStack partielle après reboot |

Recommandations : affiner l'IAM par rôle, valider les refus SCP sur AWS réel, ajouter KMS selon les besoins et la compatibilité, prévoir un pipeline de livraison de logs résilient, activer les Flow Logs si le périmètre le permet, et maintenir une procédure de reprise testée.

## 7. Coûts - estimation qualitative pour AWS réel

MiniStack local ne déclenche pas de facture AWS pour les ressources simulées. Un déploiement réel pourrait engendrer des coûts liés à :

- S3 : volumes stockés, requêtes, versioning, rétention, réplication éventuelle.
- CloudTrail : événements et options de journalisation supplémentaires selon le périmètre.
- CloudWatch Logs et VPC Flow Logs si activés : ingestion, stockage et consultations.
- AWS KMS si des CMK sont utilisées : clés et opérations cryptographiques.
- Connectivité réseau, NAT Gateway et transferts si ajoutés ultérieurement.

Aucune estimation chiffrée fiable ne peut être donnée sans région, volumes d'événements, rétention, trafic, services et tarifs actualisés. Avant un déploiement AWS réel, renseigner ces hypothèses dans AWS Pricing Calculator et définir un budget/alertes de facturation.

## 8. Preuves et reproduction

- Rapports : `evidence/security-scans/checkov-final.json`, `trivy-initial.json`.
- Détection : `evidence/detection/alerts_attack_test.json`, `test_events_synthetiques.json`.
- Object Lock : `evidence/object-lock/test-results.md`.
- Limitations : `docs/limitations-ministack.md`.
- Code de déploiement : `infra/`.
- Procédure de reprise : `PROCEDURE.md`.

Ne pas publier `terraform.tfstate`, les sauvegardes privées ou les données persistantes.
