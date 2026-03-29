# 1. Configuração do Provedor (Avisando o Terraform que vamos usar o Azure)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# 2. Inicializando o provedor do Azure
provider "azurerm" {
  features {} # Bloco obrigatório do Azure, mesmo que vazio
}

# 3. O nosso primeiro recurso: O Resource Group
# No Azure, quase toda a infraestrutura precisa ficar dentro de uma "pasta lógica" chamada Resource Group.
resource "azurerm_resource_group" "rg_telecom" {
  name     = "rg-telecom-data-lakehouse-prod"
  location = "East US" # Região onde os servidores vão ficar
}

# 4. A Conta de Armazenamento (O "Disco Duro" do nosso Data Lake)
resource "azurerm_storage_account" "datalake_telecom" {
  name                     = "dltelecomroseli2026" # Regra da Azure: letras minúsculas, sem espaço e globalmente único
  resource_group_name      = azurerm_resource_group.rg_telecom.name
  location                 = azurerm_resource_group.rg_telecom.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # A MÁGICA DO DATA LAKE AQUI:
  # Se for false, é um armazenamento de arquivos comum. Se for true, vira um Data Lake Gen2.
  is_hns_enabled           = true 
}

# 5. Os Contêineres da Arquitetura Medallion (Onde os dados vão morar)
resource "azurerm_storage_data_lake_gen2_filesystem" "camadas" {
  for_each           = toset(["bronze", "silver", "gold"])
  name               = each.key
  storage_account_id = azurerm_storage_account.datalake_telecom.id
}