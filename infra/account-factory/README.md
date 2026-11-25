# Account factory - module de création d'un compte

Module OpenTofu **proposé pour compléter le cahier des charges**. Il n'a pas été exécuté dans le MiniStack de l'utilisateur. Il n'écrase aucun compte ni état existant.

## Fonction
- Créer un nouveau compte de développement dans AWS Organizations.
- Le rattacher à une OU Workloads existante via `parent_id`.
- Appliquer des tags d'identification et de responsabilité.
- Hériter des SCP attachées à cette OU : vérifier l'héritage dans l'émulateur et sur AWS réel.

## Utilisation prévue
Le module prend un provider `aws` préconfiguré avec **Organizations pointant vers MiniStack**. Exemple de bloc dans un nouveau stack appelant :

```hcl
module "dev_team" {
  source        = "../account-factory"
  account_name  = "DEV-TEAM-ALPHA"
  account_email = var.account_email
  parent_id     = var.workloads_ou_id
}
```

Ne pas saisir de vrais identifiants AWS. Pour un nouveau stack, définir le provider local et les variables en dehors du code. Le compte Management doit être utilisé. Avant `apply`, vérifier que l'OU existe et que la SCP y est attachée.

`account_email` est une adresse de contact de laboratoire paramétrée, et ne doit pas être committée si elle est personnelle. En AWS réel, la création de comptes impose des contraintes d'identité et d'e-mail spécifiques.

## Test de réception
1. `tofu fmt -check` et `tofu validate` dans le stack appelant.
2. `tofu plan` sans remplacement d'une ressource existante.
3. `tofu apply` dans un environnement isolé de test.
4. `organizations describe-account`, `list-parents` et `list-policies-for-target`.
5. Démontrer un refus de l'action protégée si l'émulateur le permet.

Limites : pas de baseline IAM/VPC injectée automatiquement dans le nouveau compte. Le module couvre la **création et le rattachement** uniquement. La sécurisation complète du nouveau compte nécessite des modules additionnels et reste à valider.
