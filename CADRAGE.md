# Note de cadrage - DataHelix

## Contexte
DataHelix est une scale-up fictive de 400 salariés qui exploite un SaaS Data. Les ressources cloud étaient historiquement regroupées dans un seul compte, avec des autorisations larges et des journaux incomplets. Le besoin métier est de préparer une démarche SOC 2 sur six mois.

Ce projet académique reproduit une Landing Zone en local, sans compte AWS réel et sans facturation. Durée de référence du sujet : cinq jours, 35 heures, équipe de 2 à 3.

## Objectifs et critères
- Isoler PROD, STAGING, DEV, SECURITY et LOG-ARCHIVE dans une organisation AWS simulée.
- Appliquer des garde-fous SCP et une base IAM/réseau décrite par OpenTofu.
- Centraliser les événements sensibles et disposer de trois détections démontrables.
- Protéger les journaux en S3 et analyser l'IaC avec Checkov/Trivy.
- Documenter les limites de MiniStack et le coût d'une cible AWS réelle.
- Rendre les scripts, décisions et preuves faciles à réutiliser par une autre équipe.

## Périmètre et hors périmètre
Inclus : cinq comptes membres simulés, OU, SCP, VPC, IAM, S3, CloudTrail, détecteur Python, analyse statique et documentation.

Hors périmètre : cloud AWS réel, carte bancaire, application métier Docker optionnelle, SOC 2 certifié, validation complète des flux réseau et de l'application IAM/SCP par AWS.

## Architecture et approche
- Management : gouvernance, Organizations et configuration du Trail.
- Workloads : PROD, STAGING, DEV, chacun avec un VPC dédié.
- Security : SECURITY pour l'audit, LOG-ARCHIVE pour l'archivage.
- Modules OpenTofu indépendants : Organizations, IAM DEV, S3, CloudTrail, Network.
- Contrôles de sécurité : séparation des comptes, permissions de lecture, règles réseau restrictives, versioning et rétention.

## Plan de travail de référence
| Journée | Livrable attendu | État du laboratoire |
| --- | --- | --- |
| J1 | Cadrage, architecture, périmètre | Document reconstruit pour le rendu final |
| J2 | Organizations, OU, SCP, comptes | Réalisé et observé |
| J3 | Réseau, IAM, CloudTrail, bucket S3 | Réalisé et observé avant incident |
| J4 | Détection Python, sécurité, tests | Réalisé, tests synthétiques |
| J5 | Preuves, coûts, audit, rendu et démo | Dossier consolidé, démo complète non rejouée |

La note a été reconstituée en fin de projet. Elle ne constitue pas une preuve qu'un document avait été remis à la fin de J1.

## Répartition de l'équipe
Le sujet prévoit 2 à 3 personnes. La répartition effective n'a pas été renseignée dans les preuves disponibles. Proposition pour reproduction : une personne IaC/Organizations, une personne CloudTrail/S3/détection, une personne tests/rapport/démonstration. Adapter aux contributeurs réels.

## Critères de réception
- Comptes, OU, SCP et baseline décrits en IaC.
- Preuves de création des VPC, rôle d'audit, trail, protections S3.
- Trois alertes de détection sur le jeu synthétique et zéro sur les trois événements bénins enregistrés.
- Rapports Checkov et Trivy conservés avec le détail des échecs.
- Procédure reproductible et limites documentées.

## Sources
- Sujet fourni : `M1-07_Sécurité_Cloud.pdf`, pages 1 à 9.
- Preuves locales et commandes d'exécution du laboratoire DataHelix.
