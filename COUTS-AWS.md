# Estimation mensuelle AWS - DataHelix

## Périmètre de calcul
Le laboratoire MiniStack coûte **0 EUR de services AWS**, puisqu'il tourne entièrement en local. Le budget ci-dessous est une **simulation illustrative** de l'architecture cible en région Europe (Paris), et non une facture ni un devis officiel.

Hypothèses de capacité mensuelle pour une petite Landing Zone, à remplacer avant mise en production :
- 5 comptes membres et 1 compte de management.
- 100 Go de journaux en S3 Standard ; 1 million de requêtes PUT et 0,5 million de requêtes GET.
- Un trail organisationnel de management events, sans événements de données avancés.
- 50 Go de CloudWatch Logs ingérés et conservés un mois.
- 20 Go de VPC Flow Logs ingérés.
- 3 clés KMS gérées par le client, hors facturation des opérations cryptographiques.
- Pas d'EC2, NAT Gateway, VPN, transfert interrégion ou trafic applicatif dans le calcul de base.

## Calcul d'ordre de grandeur - hypothèses tarifaires à confirmer

| Poste | Quantité | Hypothèse unitaire illustrative en USD | Sous-total USD/mois |
| --- | ---: | ---: | ---: |
| AWS Organizations / comptes | 6 comptes | 0 | 0,00 |
| CloudTrail management events - 1er trail | 1 | 0, hors coûts de stockage selon hypothèses | 0,00 |
| S3 Standard | 100 Go | 0,025 / Go-mois | 2,50 |
| S3 PUT | 1 million | 0,005 / 1 000 | 5,00 |
| S3 GET | 0,5 million | 0,0004 / 1 000 | 0,20 |
| CloudWatch Logs ingestion | 50 Go | 0,60 / Go | 30,00 |
| VPC Flow Logs ingestion | 20 Go | 0,60 / Go | 12,00 |
| KMS CMK | 3 clés | 1,00 / clé-mois | 3,00 |
| **Total indicatif hors autres frais** | | | **52,70 USD/mois** |

**Important :** les tarifs unitaires ci-dessus sont des hypothèses pédagogiques arrondies et **non des tarifs AWS vérifiés au 25 novembre 2026**. Ils peuvent différer en région Paris et varier avec les modalités de collecte et de stockage. Ils excluent les coûts des requêtes KMS, du stockage CloudWatch, de la TVA, des transferts, des logs avancés CloudTrail, de GuardDuty, Security Hub et du calcul applicatif.

## Sensibilité
- Si le volume de logs double, les coûts d'ingestion et de stockage augmentent approximativement en proportion.
- Les VPC sans NAT ni charges de travail ne génèrent pas les mêmes coûts qu'une application déployée en production.
- L'archivage S3 avec rétention/versions peut accroître le volume réellement stocké.
- Une politique Lifecycle devrait adapter la classe de stockage et la conservation aux exigences réglementaires.

## Sécurité avancée - non budgétée
GuardDuty et Security Hub doivent figurer dans l'architecture cible AWS, mais ils ne sont pas émulés et leur coût dépend des volumes de données, des contrôles et des fonctionnalités activées. Ajouter une ligne détaillée après définition du périmètre réel.

## Vérification avant production
Utiliser **AWS Pricing Calculator** avec `eu-west-3`, les volumes de logs estimés, les classes de stockage, la rétention et les services réellement activés. Enregistrer la date, le lien de l'estimation, la devise et les paramètres retenus. Cette étape n'a pas été réalisée sur le compte AWS réel.
