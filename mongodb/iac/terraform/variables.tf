variable "project_id" {
  description = "ID do projeto"
  type        = string
}

variable "region" {
  description = "Região padrão"
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "Zonas a serem utilizadas para as VMs"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "machine_type" {
  description = "Tipo de máquina virtual"
  type        = string
  default     = "e2-medium"
}

variable "additional_disk_size" {
  description = "Tamanho do disco adicional em GB"
  type        = number
  default     = 5
}

variable "ansible_startup_script" {
  description = "Script de inicialização para instalação do Ansible"
  type        = string
  default     = "scripts/ansible_startup.sh"
}

variable "ssh_keys" {
  description = "Chave SSH pública"
  type        = string
}