resource "azurerm_consumption_budget_resource_group" "monthly_poc" {
  name              = "${local.unique_name}-monthly-budget"
  resource_group_id = azurerm_resource_group.main.id
  amount            = var.monthly_budget_usd

  time_grain = "Monthly"

  time_period {
    start_date = "2026-11-01T00:00:00Z"
    end_date   = "2027-11-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 50
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.budget_alert_emails
    contact_roles  = length(var.budget_alert_emails) == 0 ? ["Owner", "Contributor"] : []
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.budget_alert_emails
    contact_roles  = length(var.budget_alert_emails) == 0 ? ["Owner", "Contributor"] : []
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.budget_alert_emails
    contact_roles  = length(var.budget_alert_emails) == 0 ? ["Owner", "Contributor"] : []
  }
}
