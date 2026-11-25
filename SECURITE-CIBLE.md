# Dossier d'architecture et de sécurité - DataHelix

## 1. Choix architectural
| Option | Avantages | Limites | Décision |
| --- | --- | --- | --- |
| Un seul compte AWS | Simplicité initiale, peu de coordination | Risques transverses, IAM et facturation difficiles à séparer | Écarté |
| Organisation multi-comptes | Isolation administrative, responsabilités, journaux dédiés | Gouvernance plus complexe, besoin d'automatisation | Retenu |
| AWS réel | Services managés et sécurité native | Compte, paiement, risque de frais | Interdit pour l'exercice |
| MiniStack open source local | Coût cloud nul, IaC réutilisable, tests possibles | Émulation partielle, persistance imparfaite | Retenu pour le laboratoire |
| Alternative open source de production (OpenStack) | Contrôle de l'infrastructure et souveraineté possible | Maintenance, responsabilité opérationnelle, services non identiques | Alternative à étudier |

## 2. Patterns et modules
- Séparation des responsabilités par compte : limiter les effets d'une erreur.
- Baseline réseau réutilisable : mêmes conventions pour les VPC PROD, STAGING et DEV.
- Journalisation centralisée : découpler producteur d'événements et analyse.
- Infrastructure as Code : versionner et relire les contrôles avant déploiement.
- Garde-fous organisationnels : SCP en complément de l'IAM, pas en substitution.

## 3. Cartographie des actifs et des risques
La grille est inspirée d'une démarche de cartographie des risques et de principes EBIOS RM, **sans prétendre constituer une étude EBIOS RM complète**. Échelle : probabilité P et impact I de 1 (faible) à 4 (critique), score P x I.

| Actif | Événement redouté | P | I | Score | Mesure / traitement |
| --- | --- | ---: | ---: | ---: | --- |
| Compte Management | Modification non autorisée des SCP | 2 | 4 | 8 | MFA et rôles dédiés en AWS réel, revue IaC |
| Journaux CloudTrail | Suppression ou altération | 3 | 4 | 12 | S3 privé, versioning, Object Lock ; confirmer bypass |
| Comptes Workloads | Mouvement transversal entre environnements | 2 | 4 | 8 | Comptes séparés, IAM, revues SCP |
| Infrastructure réseau | Ouverture involontaire de ports | 3 | 3 | 9 | SG restrictifs, tests et scans IaC |
| Détecteur SOC | Événement sensible non détecté | 3 | 3 | 9 | Règles testées, supervision et enrichissement à prévoir |
| Laboratoire local | Perte d'état après redémarrage | 4 | 3 | 12 | Sauvegardes, preuves, reprise documentée |

## 4. SOC 2 et sécurité opérationnelle
L'architecture vise les principes de sécurité et de disponibilité : contrôle d'accès, traçabilité, gestion du changement, surveillance et continuité. Elle **ne constitue pas une certification SOC 2**. Une organisation réelle devra définir propriétaires, preuves périodiques, processus de revue et contrôles humains.

## 5. RGPD et souveraineté
- Minimiser les données personnelles dans les logs.
- Limiter les accès aux journaux et définir une durée de conservation justifiée.
- Prévoir une base légale, un registre de traitement et la procédure de gestion des violations de données si le service traite des données personnelles.
- Choisir la région cloud et vérifier les transferts hors EEE et les sous-traitants avant production.
- MiniStack est exécuté localement : aucune donnée de production nécessaire à ce projet.

## 6. Accessibilité et exploitation
- Documents Markdown structurés avec titres, tableaux simples et descriptions des schémas.
- Diagrammes fournis en PNG et formats modifiables.
- Procédure compatible terminal, commandes explicites et résultats attendus.
- Runbooks d'incident et de reprise avec preuves conservées.

## 7. Écoresponsabilité
- Éteindre les services de laboratoire hors des sessions de tests après sauvegarde propre.
- Réduire les duplications de providers et artefacts de build.
- Mettre une politique de cycle de vie des journaux selon les obligations applicables.
- Dimensionner les services AWS cibles aux volumes réels ; éviter les environnements de démonstration permanents.

## 8. Principaux risques résiduels
- Livraison CloudTrail vers S3 réalisée manuellement dans MiniStack.
- Application effective des SCP et de l'IAM non complètement vérifiée.
- Tests réseau limités à la configuration, sans trafic réel.
- Chiffrement SSE-S3 mais pas CMK KMS.
- Persistance MiniStack partielle après redémarrages.

Voir aussi [SECURITY-REPORT.md](SECURITY-REPORT.md), [TESTS.md](TESTS.md) et [COUTS-AWS.md](COUTS-AWS.md).
