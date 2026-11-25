variable "account_name" {
  type = string
  description = "Nom du nouveau compte de développement."
  validation {
    condition = length(trimspace(var.account_name)) >= 3
    error_message = "Le nom du compte doit contenir au moins 3 caractères."
  }
}

variable "account_email" {
  type = string
  description = "Adresse de contact du nouveau compte de laboratoire."
  sensitive = true
  validation {
    condition = can(regex("^[^@]+@[^@]+\.[^@]+$", var.account_email))
    error_message = "Adresse e-mail invalide."
  }
}

variable "parent_id" {
  type = string
  description = "ID de l'OU Workloads existante."
  validation {
    condition = can(regex("^ou-[a-z0-9-]+$", var.parent_id))
    error_message = "L'identifiant doit être celui d'une OU Organizations."
  }
}

variable "tags" {
  type = map(string)
  default = {}
}
