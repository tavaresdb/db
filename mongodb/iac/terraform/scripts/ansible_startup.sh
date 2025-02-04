#!/bin/bash
# Atualização dos pacotes e instalação do Ansible
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible