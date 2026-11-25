# Architecture technique - DataHelix

## 1. Vue d'ensemble

L'environnement s'exécute en local sur Ubuntu et expose les API AWS simulées par MiniStack à l'adresse `http://127.0.0.1:4566`. OpenTofu décrit les ressources dans cinq stacks distinctes.

```text
                         Management 111111111111
                      Organization o-61fa0054ec
                               Root r-5d9efe
                                    |
                   +----------------+---------------+
                   |                                |
              OU Workloads                      OU Security
                   |                                |
          +--------+--------+                 +-----+-------+
          |        |        |                 |             |
         PROD   STAGING    DEV              SECURITY     LOG-ARCHIVE
          |        |        |                 |             |
        10.10/16 10.20/16 10.30/16      Audit DEV       Bucket S3
          |        |        |                 |         Object Lock
          +--------+--------+                 |             ^
                  |                          |             |
                  +------ activités API -----+             |
                                |                         |
                       Trail organisationnel              |
                                |                         |
                        lookup-events (API)               |
                                |                         |
                       export JSON manuel ----------------+
                                |
                         Détection Python
```

## 2. Comptes simulés du laboratoire reconstruit

| Compte | Identifiant du laboratoire | Fonction |
| --- | --- | --- |
| Management | `111111111111` | AWS Organizations, administration, Trail |
| PROD | `431122467493` | Production, VPC `10.10.0.0/16` |
| STAGING | `627415924341` | Préproduction, VPC `10.20.0.0/16` |
| DEV | `153921435903` | Développement, VPC `10.30.0.0/16`, rôle d'audit |
| SECURITY | `616337743862` | Compte destiné à l'audit de sécurité |
| LOG-ARCHIVE | `888031631734` | Centralisation du stockage S3 |

Ces identifiants appartiennent à une exécution de MiniStack. **Ils peuvent changer si l'organisation est recréée.** Contrôler les outputs de `infra/organizations` avant de redéployer IAM, S3 ou Network.

## 3. Gouvernance et identités

- OU Workloads : PROD, STAGING, DEV.
- OU Security : SECURITY, LOG-ARCHIVE.
- SCP `DataHelix-Protect-Security` : destinée à refuser certaines opérations sensibles comme `cloudtrail:StopLogging`, `cloudtrail:DeleteTrail`, `cloudtrail:UpdateTrail`, `cloudtrail:PutEventSelectors` et `organizations:LeaveOrganization`.
- Rôle `DataHelix-SecurityAudit` dans DEV : permission de consulter les VPC, subnets, groupes de sécurité et tables de routage.

Le déploiement d'une SCP ou d'une politique IAM dans MiniStack ne démontre pas que son moteur d'autorisation l'applique intégralement. Le test historique SCP vérifiait notamment le contenu de la politique, pas un refus d'API effectif.

## 4. Réseau

| Environnement | VPC | Subnet privé | Groupes de sécurité |
| --- | --- | --- | --- |
| PROD | `10.10.0.0/16` | `10.10.1.0/24` | Baseline et groupe par défaut gérés |
| STAGING | `10.20.0.0/16` | `10.20.1.0/24` | Baseline et groupe par défaut gérés |
| DEV | `10.30.0.0/16` | `10.30.1.0/24` | Baseline et groupe par défaut gérés |

Le module `infra/network/modules/vpc-baseline/` crée un VPC, un subnet et un Security Group. Une ressource `aws_default_security_group` gère également le groupe par défaut. La vérification directe par ID du groupe PROD avait retourné `Ingress: []` et `Egress: []`.

## 5. Journaux et détection

- Trail : `DataHelix-Organization-Trail`, dans le compte Management, région principale `eu-west-3`.
- Destination configurée : `datahelix-log-archive-888031631734`, préfixe natif `cloudtrail/`.
- Destination testée : `lab-export/events.json`, alimentée **manuellement** depuis `lookup-events`.
- Protections S3 déclarées : versioning, SSE-S3 AES256, blocage des accès publics et politique de livraison CloudTrail.
- Protection additionnelle testée : Object Lock GOVERNANCE, rétention par défaut 7 jours. Une suppression de version test a été refusée.
- Détecteur `scripts/detect_cloudtrail.py` : DET-001 (CloudTrail), DET-002 (Organizations/SCP), DET-003 (protection S3).

## 6. Frontières de confiance et limites

- Les comptes sont simulés, sans isolement cloud réel.
- Les VPC déclarés ne constituent pas des réseaux fonctionnels traversés par des flux réels dans le laboratoire.
- Le chiffrement retourné par l'API S3 ne garantit pas un chiffrement réel des données sur le disque Ubuntu.
- Les événements collectés et les tests de détection ne prouvent pas une visibilité complète sur tous les comptes membres.
- La persistance MiniStack s'est révélée partielle après redémarrage imprévu.

Pour les commandes et l'ordre de déploiement, voir [PROCEDURE.md](PROCEDURE.md).
