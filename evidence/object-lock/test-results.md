# Test de protection S3 Object Lock - DataHelix

## Environnement

- Plateforme : MiniStack 1.5.40
- Compte : LOG-ARCHIVE (888031631734)
- Bucket : datahelix-log-archive-888031631734
- Objet : security-tests/test-protection.txt

## Configuration

- Versioning : Enabled
- Chiffrement configuré : SSE-S3 (AES256)
- Object Lock : Enabled
- Mode : GOVERNANCE
- Rétention : 7 jours

## Test réalisé

1. Création d'un nouvel objet dans S3.
2. Récupération de son identifiant de version.
3. Vérification de sa rétention.
4. Tentative de suppression définitive sans contournement.

## Résultats

- VersionId : bda68998-a3c6-4615-9b4a-487880e01eae
- RetainUntilDate : 2026-12-01T17:07:25+00:00
- Suppression : refusée.
- Erreur : AccessDenied - object protected by object lock.

## Conclusion

PASS - MiniStack a refusé la suppression de la version protégée.

Limite : le test ne démontre pas la résistance à un contournement
autorisé du mode GOVERNANCE ni le comportement d'AWS réel.
