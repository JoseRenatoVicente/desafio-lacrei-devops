variable "organization_name" {
  description = "Nome da organização"
  type        = string
}

variable "environment" {
  description = "Ambiente (staging, production, etc)"
  type        = string
}

variable "api_id" {
  description = "ID da API Gateway"
  type        = string
}

variable "alarm_email" {
  description = "Email para notificações de alarme"
  type        = string
}

variable "latency_threshold" {
  description = "Limiar de latência em segundos"
  type        = number
  default     = 5
}

variable "error_rate_threshold" {
  description = "Porcentagem de erros 5xx aceitável"
  type        = number
  default     = 1
}
