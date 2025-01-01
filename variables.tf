variable "rg" {}

variable "virtual_machine_id" {}

variable "managed_disks" {
  type = map(object({
    disk_size_gb                   = string
    virtual_machine_attachment_lun = number
    storage_account_type           = optional(string)
    virtual_machine_attachment_caching = optional(string, "ReadWrite")
  }))
  default = {}
}

variable "extensions" {
  type = map(object({
    publisher                  = string
    type                       = string
    auto_upgrade_minor_version = optional(bool, true)
    type_handler_version       = string
    settings                   = optional(string)
    protected_settings         = optional(string)
    provision_after_extensions  = optional(list(string), [])
  }))
  default = {}
}

variable "shutdown_schedule" {
  type = object({
    enabled = optional(bool, true)
    daily_recurrence_time = optional(string)
    timezone              = optional(string, "UTC")
    notification_settings = optional(object({
      enabled = optional(bool, true)
      email = optional(string)
      time_in_minutes = optional(number)
      webhook_url = optional(string)
    }), {enabled = false})
  })
  default = {enabled = false}
  nullable = false
}