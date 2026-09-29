variable "enable" {
  default     = true
  description = "Whether the detector is enabled. Disabling it stops analysis but keeps the detector and its configuration."
}

variable "finding_publishing_frequency" {
  default     = "FIFTEEN_MINUTES"
  description = "How often findings are published to EventBridge and to a member account's administrator (e.g. 'FIFTEEN_MINUTES', 'ONE_HOUR', or 'SIX_HOURS'). AWS defaults to six hours; this module defaults to fifteen minutes, because a detection you hear about six hours late is a report rather than an alert."

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "finding_publishing_frequency must be 'FIFTEEN_MINUTES', 'ONE_HOUR' or 'SIX_HOURS'."
  }
}

variable "features" {
  description = "Optional protection features to turn on beyond the baseline (e.g. 'S3_DATA_EVENTS', 'EKS_AUDIT_LOGS', 'EBS_MALWARE_PROTECTION', 'RDS_LOGIN_EVENTS', 'LAMBDA_NETWORK_LOGS', 'RUNTIME_MONITORING'). Each is billed separately — see the README."
  type = list(object({
    name   = string
    status = optional(string, "ENABLED")
  }))
  default = []
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the detector."
}
