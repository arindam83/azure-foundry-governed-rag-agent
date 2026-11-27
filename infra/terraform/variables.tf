variable "project_name" {
  description = "Short project identifier used in Azure resource names."
  type        = string
  default     = "ragagent"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{2,20}$", var.project_name))
    error_message = "project_name must be 2-20 letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{2,12}$", var.environment))
    error_message = "environment must be 2-12 letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region for the resource group and services."
  type        = string
  default     = "centralus"
}


variable "resource_group_name" {
  description = "Optional resource group name. A unique name is generated when null."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "monthly_budget_usd" {
  description = "Monthly subscription-to-resource-group POC budget threshold in USD."
  type        = number
  default     = 25

  validation {
    condition     = var.monthly_budget_usd > 0
    error_message = "monthly_budget_usd must be greater than zero."
  }
}

variable "budget_alert_emails" {
  description = "Optional email addresses to notify at POC budget thresholds."
  type        = list(string)
  default     = []
  sensitive   = true
}