variable "rails_master_key" {
  description = "Rails master key (contents of config/master.key)"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Email address to notify when HTTP 5xx alerts fire"
  type        = string
}
