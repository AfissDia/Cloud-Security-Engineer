# Runbooks - DataHelix

Ces opérations s'appliquent à **MiniStack local**. Elles ne doivent pas être exécutées contre un compte AWS réel. Les comptes et identifiants présentés dans les autres documents correspondent à une exécution précédente.

## RB-01 - Démarrage sécurisé
1. Vérifier le disque avec `df -h /` et l'état du dépôt `git status`.
2. Définir `PERSIST_STATE=1`, `S3_PERSIST=1`, `STATE_DIR` et `S3_DATA_DIR` avant de démarrer MiniStack.
3. Démarrer une seule instance MiniStack dans le terminal dédié.
4. Vérifier l'endpoint : `aws --endpoint-url=http://127.0.0.1:4566 sts get-caller-identity`.
5. Vérifier la liste des comptes, les VPC, CloudTrail, le bucket et Object Lock en lecture seule.
6. Ne jamais lancer `tofu apply` avant d'avoir comparé l'état réel et `terraform.tfstate`.

## RB-02 - Incident de persistance
**Symptôme :** Organizations et IAM présents, mais CloudTrail, VPC ou Object Lock introuvables après redémarrage.

1. Ne pas supprimer les fichiers `terraform.tfstate`.
2. Copier les fichiers d'état et la persistance MiniStack hors du dépôt public.
3. Examiner les dates dans `ministack-data/state/`.
4. Lister les ressources par compte via AWS CLI, en lecture seule.
5. Relever l'écart entre état OpenTofu et services simulés.
6. Si la démonstration est imminente, utiliser les preuves enregistrées et déclarer la limite.
7. Toute restauration doit se faire sur une copie avec `tofu plan` inspecté, jamais avec `destroy` automatique.

## RB-03 - Échec CloudTrail
1. Vérifier que le provider OpenTofu définit bien l'endpoint `cloudtrail` local.
2. Vérifier le compte de management avec `sts get-caller-identity`.
3. Lire la configuration par `describe-trails` et `get-trail-status`.
4. Pour l'export manuel, utiliser `lookup-events` et conserver le JSON en preuve.
5. Ne pas affirmer que `IsLogging: true` démontre la livraison native dans S3.

## RB-04 - Erreur S3 AccessDenied dans OpenTofu
1. Comparer l'identité active avec l'ID du compte LOG-ARCHIVE.
2. Vérifier la présence du bucket par `list-buckets`.
3. Inspecter le plan dans le bon contexte de compte.
4. Ne pas modifier la policy pour corriger une erreur liée à un mauvais compte.

## RB-05 - Incident de journalisation ou alerte
1. Conserver l'événement source JSON avant modification.
2. Identifier l'événement, le compte et l'heure signalés.
3. Rejouer le détecteur Python sur une copie du fichier.
4. Qualifier alerte vraie, faux positif ou donnée insuffisante.
5. Documenter l'action : enquête, remédiation, horodatage et preuve.
6. Le jeu d'événements synthétiques n'est pas une preuve d'attaque réelle.

## RB-06 - Protection des objets de preuve
1. Vérifier versioning et configuration Object Lock du bucket LOG-ARCHIVE.
2. Tester uniquement avec une nouvelle clé `security-tests/`.
3. Vérifier `get-object-retention` avec le `VersionId` créé.
4. En mode GOVERNANCE, `delete-object --version-id` doit être refusé sans permission de contournement si l'émulateur applique la rétention.
5. Ne jamais tester une suppression sur de véritables journaux.

## RB-07 - Sauvegarde et publication
```bash
cd ~/projet7-datahelix
mkdir -p ~/datahelix-final-backup
tar -czf ~/datahelix-final-backup/code-et-preuves.tar.gz \
  --exclude='.terraform' --exclude='.venv' --exclude='.venv-checkov' \
  --exclude='terraform.tfstate' --exclude='terraform.tfstate.backup' \
  --exclude='ministack-data' \
  infra scripts tests evidence docs README.md
```

- Sauvegarder `terraform.tfstate` et `ministack-data` dans une archive **privée** distincte.
- Vérifier les archives avec `tar -tzf`.
- Avant GitHub : `git status`, `.gitignore`, recherche de secrets et inspection du diff.
