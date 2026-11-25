# Intégration du rendu final au dépôt existant

## Ce que contient ce pack
- La documentation consolidée DataHelix, les images et les diagrammes techniques.
- Une proposition de module OpenTofu `infra/account-factory` et deux scripts d'exploitation.
- Une licence MIT et un `.gitignore`.

## Ce que ce pack NE contient PAS
Les cinq stacks OpenTofu du laboratoire (`organizations`, `iam-dev`, `log-archive`, `cloudtrail`, `network`), le détecteur Python original et les fichiers de preuves JSON réels. Ces éléments sont **uniquement sur le PC de l'utilisateur**. Ce ZIP ne constitue pas à lui seul un dépôt exécutable.

## Installer sans écraser ton code
1. Sauvegarder le dossier local `~/projet7-datahelix`.
2. Décompresser le ZIP dans un répertoire temporaire.
3. Copier les documents `.md`, `diagrams/` et `docs/` dans le dépôt local.
4. Ajouter `infra/account-factory/` et les nouveaux scripts sans modifier les cinq stacks existants.
5. Comparer et fusionner `.gitignore` au lieu d'écraser les exclusions déjà présentes.
6. Vérifier et personnaliser la licence MIT avec les titulaires réels du droit d'auteur.
7. Lancer `bash scripts/verify-rendu.sh` et inspecter `git diff`.
8. Ne pas publier `terraform.tfstate`, `.tfvars`, `ministack-data`, les sauvegardes et les données privées.

## Déploiement global
Le script `scripts/deploy-all.sh` est un **orchestrateur de validation/proposition**, non testé sur les cinq stacks réels. Il impose une revue interactive de chaque plan lors de `apply` : une 'commande unique' pour lancer la séquence ne garantit pas l'autonomie ni la compatibilité des stacks. Ne pas l'utiliser pour réparer la perte partielle d'état actuelle.

Variables nécessaires, à renseigner pour un environnement MiniStack **neuf et cohérent** :

```bash
export DATAHELIX_MGMT_ID='111111111111'
export DATAHELIX_DEV_ID='<12 chiffres>'
export DATAHELIX_LOG_ID='<12 chiffres>'
export DATAHELIX_PROD_ID='<12 chiffres>'
export DATAHELIX_STAGING_ID='<12 chiffres>'

bash scripts/deploy-all.sh validate
bash scripts/deploy-all.sh plan
# Ne faire apply qu'après synchronisation des IDs / ARN / variables et revue.
```

Le bootstrap de l'organisation et la création des nouveaux comptes modifient les identifiants : le script ne peut pas déduire automatiquement les dépendances sans examiner les modules existants. L'objectif académique 'une commande pour déployer toute la Landing Zone' **n'est donc pas encore démontré**.

## Vérifications indispensables avant rendu
- Les noms de ressources dans la documentation correspondent bien aux fichiers `.tf`.
- Les rapports de scan sont conservés et leurs écarts expliqués.
- Les tests du module account-factory et le flux centralisé sont clairement marqués non validés.
- Toutes les illustrations conservent la mention laboratoire simulé si nécessaire.
- La licence convient aux auteurs du projet.
