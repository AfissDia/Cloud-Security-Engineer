# Guide de lecture et de partage - DataHelix

## À qui s'adresse ce rendu ?

Ce dossier s'adresse à un évaluateur, un étudiant, un recruteur ou une personne souhaitant comprendre et reproduire une architecture AWS multi-comptes **simulée localement**.

Aucune connaissance du déroulement du projet n'est nécessaire pour lire le rendu.

## Parcours conseillé

| Besoin | Document |
| --- | --- |
| Comprendre le projet rapidement | [README](../README.md) |
| Visualiser les comptes, réseaux et flux de journaux | [Architecture](../ARCHITECTURE.md) |
| Reproduire le laboratoire avec le code | [Procédure](../PROCEDURE.md) |
| Examiner les tests, risques et résultats d'audit | [Rapport de sécurité](../SECURITY-REPORT.md) |
| Présenter une démonstration courte | [Démonstration](../DEMO.md) |
| Comprendre les limites de MiniStack | [Limites](limitations-ministack.md) |

## Ce qui est fourni dans ce pack

- Des documents Markdown structurés et liés entre eux.
- Deux schémas visuels au format PNG et SVG.
- Les fichiers sources Graphviz `.dot` pour modifier les schémas.
- Un exemple de règles `.gitignore` pour un dépôt public.

**Important :** le pack documentaire ne contient pas les fichiers `.tf`, scripts Python ni preuves du dépôt local original. Pour disposer d'un laboratoire reproductible, il faut l'intégrer au dépôt de code qui contient `infra/`, `scripts/`, `tests/` et `evidence/`. Les commandes de la procédure se rapportent à ce dépôt complet.

## Lire correctement les résultats

- « Déployé » signifie qu'une création a été observée dans MiniStack au moment du test.
- « Testé » signifie qu'une commande ou un contrôle a produit une preuve concrète.
- « Synthétique » signifie que l'événement a été fabriqué pour valider un détecteur, sans attaque réelle.
- Les scores Checkov (82,1 %) et Trivy (97,6 %) sont des **scores bruts** mesurés lors du projet, pas une certification.
- Après un redémarrage imprévu, certaines ressources simulées ont disparu. Les documents décrivent les validations **historiques**, pas un état de production permanent.

## Reproduction sur un autre poste

1. Récupérer le dépôt de code complet et consulter sa configuration.
2. Installer les outils et préparer un espace disque suffisant.
3. Démarrer MiniStack, puis suivre [PROCEDURE.md](../PROCEDURE.md) dans l'ordre.
4. Remplacer les identifiants d'exemple par les outputs de la nouvelle organisation.
5. En cas de perte partielle d'état MiniStack, **ne pas appliquer les anciens états OpenTofu aveuglément**.

## Publication GitHub

Avant de publier :

- Vérifier `git status` et `git diff --cached`.
- Exclure `terraform.tfstate`, les sauvegardes privées, `ministack-data/`, `.venv*` et `.terraform/`.
- Vérifier les fichiers de preuves pour retirer tout secret ou donnée personnelle éventuels.
- Conserver les dates, captures et résultats réels des tests, sans les présenter comme une démo exécutée sur AWS réel.
- Ne jamais publier de clés AWS réelles.

Les identifiants numériques du laboratoire sont des **identifiants fictifs MiniStack**. Ils servent uniquement de références d'une exécution et ne doivent pas être réutilisés tels quels sur un nouveau laboratoire.
