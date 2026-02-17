variable "name" {
  description = "Name of the control plane"
  type        = string
}

variable "description" {
  description = "Description of the control plane."
  type        = string
  default     = "My AWS control plane description"
}

variable "token-secret-arn" {
  description = "Control plane secret token ARN."
  type        = string
}

variable "subnets" {
  description = "The subnet IDs for the control plane."
  type        = list(string)

  validation {
    condition     = length(var.subnets) > 0
    error_message = "Subnets must not be empty."
  }
}

variable "security-groups" {
  description = "Security group IDs to be used with the control plane."
  type        = list(string)

  validation {
    condition     = length(var.security-groups) > 0
    error_message = "Security groups must not be empty."
  }
}

variable "assign-public-ip" {
  description = "Assign public IP to the control plane service."
  type        = bool
  default     = true
}

variable "git" {
  description = "Control plane git configuration."
  type = object({
    credentials = optional(object({
      username         = optional(string, "")
      token-secret-arn = optional(string, "")
    }), {})
    ssh = optional(object({
      private-key-secret-arn = optional(string, "")
    }), {}),
    cache = optional(object({
      paths = optional(list(string), [])
    }), {})
  })
  default = {}

  validation {
    condition = (
      length(var.git.credentials.username) == 0 ||
      length(var.git.credentials.token-secret-arn) > 0
    )
    error_message = "When credentials.username is set, credentials.token-secret-arn must also be provided."
  }
}

variable "task" {
  description = "Control plane task definition."
  type = object({
    cpu    = optional(string, "1024")
    memory = optional(string, "3072")
    image  = optional(string, "gatlingcorp/control-plane:latest")
    init = optional(object({
      image       = optional(string, "busybox")
      command     = optional(list(string), [])
      environment = optional(list(map(string)), [])
      secrets     = optional(list(map(string)), [])
    }), {})
    command         = optional(list(string), [])
    secrets         = optional(list(map(string)), [])
    environment     = optional(list(map(string)), [])
    cloudwatch-logs = optional(bool, true)
    ecr             = optional(bool, false)
  })
  default = {}
}

variable "locations" {
  description = "Configuration for the private locations."
  type = list(object({
    id            = string
    description   = optional(string, "Private Location on AWS")
    region        = string
    engine        = optional(string, "classic")
    instance-type = optional(string, "c7i.xlarge")
    spot          = optional(bool, false)
    ami = optional(object({
      type = optional(string, "certified")
      java = optional(string, "latest")
      id   = optional(string)
    }), {})
    subnets                    = list(string)
    security-groups            = list(string)
    auto-associate-public-ipv4 = optional(bool, true)
    elastic-ips                = optional(list(string), [])
    profile-name               = optional(string, null)
    iam-instance-profile       = optional(string, null)
    tags                       = optional(map(string), {})
    tags-for = optional(object({
      instance          = optional(map(string), {})
      volume            = optional(map(string), {})
      network-interface = optional(map(string), {})
    }), {})
    system-properties = optional(map(string), {})
    java-home         = optional(string, null)
    jvm-options       = optional(list(string), [])
    enterprise-cloud  = optional(map(any), {})
  }))

  validation {
    condition     = alltrue([for loc in var.locations : can(regex("^prl_[0-9a-z_]{1,26}$", loc.id))])
    error_message = "Private location ID must be prefixed by 'prl_', contain only numbers, lowercase letters, and underscores, and be at most 30 characters long."
  }

  validation {
    condition     = alltrue([for loc in var.locations : contains(["classic", "javascript"], loc.engine)])
    error_message = "The engine must be either 'classic' or 'javascript'."
  }

  validation {
    condition     = alltrue([for loc in var.locations : length(loc.region) > 0])
    error_message = "Region must not be empty."
  }

  validation {
    condition     = alltrue([for loc in var.locations : length(loc.subnets) > 0])
    error_message = "Location subnets must not be empty."
  }

  validation {
    condition     = alltrue([for loc in var.locations : length(loc.security-groups) > 0])
    error_message = "Location security groups must not be empty."
  }

  validation {
    condition     = alltrue([for loc in var.locations : loc.ami.type != "custom" || loc.ami.id != null])
    error_message = "If ami.type is 'custom', then ami.id must be specified."
  }

  validation {
    condition     = alltrue([for loc in var.locations : !(loc.auto-associate-public-ipv4 && length(loc.elastic-ips) > 0)])
    error_message = "When elastic_ips are provided, auto-associate-public-ipv4 must be false."
  }
}

variable "private-package" {
  description = "Configuration for the private package (S3-based)."
  type = object({
    bucket = string
    path   = optional(string, "")
    upload = optional(object({
      directory = string
    }), { directory = "/tmp" })
  })
  default = null

  validation {
    condition     = var.private-package == null || length(var.private-package.bucket) > 0
    error_message = "Bucket name of the S3 private package must not be empty."
  }
}

variable "enterprise-cloud" {
  description = "Enterprise Cloud network settings: http proxy, fwd proxy, etc."
  type        = map(any)
  default     = {}
}

variable "extra-content" {
  type    = map(any)
  default = {}
}

variable "certificates" {
  description = <<-EOT
    Content of custom CA certificates in PEM format to be added to the Java truststore.
    Use file() function to load from a file: certificates = file("path/to/cert.pem")
    Multiple certificates can be included in a single PEM file.
    Leave empty or omit to skip certificate installation.
  EOT
  type        = string
  default     = ""
}
variable "server" {
  description = "Control Plane Repository Server configuration."
  type = object({
    port        = optional(number, 8080)
    bindAddress = optional(string, "0.0.0.0")
    certificate = optional(object({
      path     = optional(string)
      password = optional(string, null)
    }), null)
  })
  default = {}

  validation {
    condition     = var.server.port > 0 && var.server.port <= 65535
    error_message = "Server port must be between 1 and 65535."
  }
  validation {
    condition     = length(var.server.bindAddress) > 0
    error_message = "Server bindAddress must not be empty."
  }
}
