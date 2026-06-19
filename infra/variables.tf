variable "rails_master_key" {
  description = "Rails master key (contents of config/master.key)"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email address to notify when HTTP 5xx alerts fire"
  type        = string
}

variable "oracle_database_url" {
  description = "Oracle Enhanced adapter DATABASE_URL — oracle-enhanced://user:pass@host:1521/service"
  type        = string
  sensitive   = true
}
