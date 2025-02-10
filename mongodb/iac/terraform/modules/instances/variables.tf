variable "project_id" {
  description = "ID do projeto"
  type        = string
}

variable "zones" {
  description = "Zonas a serem utilizadas para as VMs"
  type        = list(string)
}

variable "instance_name_prefix" {
  description = "Prefixo do nome da máquina virtual"
  type        = string
}

variable "counter" {
  description = "Sufixo do nome da máquina virtual"
  type        = number
}

variable "machine_type" {
  description = "Tipo de máquina virtual"
  type        = string
}

variable "tags" {
  description = "Tags adicionadas as VMs"
  type        = list(string)
}

variable "network" {
  description = "A variável aceitará o valor transmitido fora do módulo"
  type        = string
}

variable "subnetwork" {
  description = "A variável aceitará o valor transmitido fora do módulo"
  type        = string
}

variable "additional_disk" {
  description = "Definirá se um disco adicional deve ser adicionado ou não"
  type        = bool
}

variable "additional_disk_size" {
  description = "Tamanho do disco adicional em GB"
  type        = number
}

variable "startup_script" {
  description = "Script de inicialização para instalação do Ansible"
  type        = string
}

variable "ssh_keys" {
  description = "Chave SSH pública"
  type        = string
}