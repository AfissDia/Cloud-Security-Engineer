# Démonstration courte - DataHelix

Durée cible : 5 à 7 minutes. Utiliser les preuves si MiniStack n'est pas entièrement disponible.

## 1. Présenter le contexte

« DataHelix est une Landing Zone AWS multi-comptes réalisée localement avec MiniStack et déployée avec OpenTofu. Le but est de séparer les environnements, limiter les accès et collecter les journaux de sécurité. »

## 2. Expliquer l'architecture

Montrer `ARCHITECTURE.md` et le module `infra/network/`.

« Nous avons un compte de management, cinq comptes membres, deux unités organisationnelles, une SCP et trois VPC distincts pour PROD, STAGING et DEV. »

## 3. Montrer la chaîne SOC

```bash
python3 scripts/detect_cloudtrail.py tests/fixtures/cloudtrail_attack_events.json
```

« Trois événements synthétiques représentent l'arrêt de CloudTrail, la modification d'une SCP et la suppression d'une protection S3. Le détecteur produit trois alertes. Les événements réellement collectés dans MiniStack n'avaient pas déclenché d'alerte sur le premier jeu de test. »

## 4. Montrer les preuves de sécurité

Ouvrir `evidence/object-lock/test-results.md` et le rapport `SECURITY-REPORT.md`.

« Une tentative de suppression d'une version S3 protégée par Object Lock en mode GOVERNANCE a été refusée. Checkov a donné 82,1 % et Trivy 97,6 % de contrôles réussis sur leurs scans bruts. »

## 5. Mentionner les limites et conclure

« L'environnement est simulé : l'export CloudTrail vers S3 a été manuel, certaines autorisations ne sont pas totalement testées et plusieurs services n'ont pas conservé leur état après un redémarrage inattendu. Le code et les preuves ont été conservés pour permettre une reprise. »

« Ce projet m'a permis de pratiquer le Cloud Security, l'IaC avec OpenTofu, la journalisation CloudTrail et les premières détections SOC. »
