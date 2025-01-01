module "managed_disks" {
  source               = "app.terraform.io/ptonini-org/managed-disk/azurerm"
  version              = "~> 1.0.0"
  for_each             = var.managed_disks
  rg                   = var.rg
  name                 = each.key
  storage_account_type = each.value.storage_account_type
  disk_size_gb         = each.value.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each           = module.managed_disks
  virtual_machine_id = var.virtual_machine_id
  managed_disk_id    = each.value.this.id
  lun                = var.managed_disks[each.key].virtual_machine_attachment_lun
  caching            = var.managed_disks[each.key].virtual_machine_attachment_caching
}

resource "azurerm_virtual_machine_extension" "this" {
  for_each                   = var.extensions
  virtual_machine_id         = var.virtual_machine_id
  name                       = each.key
  publisher                  = each.value.publisher
  type                       = each.value.type
  auto_upgrade_minor_version = each.value.auto_upgrade_minor_version
  type_handler_version       = each.value.type_handler_version
  provision_after_extensions = each.value.provision_after_extensions
  settings                   = each.value.settings
  protected_settings         = each.value.protected_settings

  lifecycle {
    ignore_changes = [
      tags["business_unit"],
      tags["environment"],
      tags["product"],
      tags["subscription_type"]
    ]
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  count                 = var.shutdown_schedule.enabled ? 1 : 0
  virtual_machine_id    = var.virtual_machine_id
  location              = var.rg.location
  enabled               = var.shutdown_schedule.enabled
  daily_recurrence_time = var.shutdown_schedule.daily_recurrence_time
  timezone              = var.shutdown_schedule.timezone

  notification_settings {
    enabled         = var.shutdown_schedule.notification_settings.enabled
    email           = var.shutdown_schedule.notification_settings.email
    time_in_minutes = var.shutdown_schedule.notification_settings.time_in_minutes
    webhook_url     = var.shutdown_schedule.notification_settings.webhook_url
  }
}