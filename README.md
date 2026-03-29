flowchart LR
    %% Definição de Cores e Estilos
    classDef infra fill:#f9f9f9,stroke:#333,stroke-width:2px,stroke-dasharray: 5 5;
    classDef storage fill:#0078D4,stroke:#fff,stroke-width:2px,color:#fff;
    classDef compute fill:#FF3621,stroke:#fff,stroke-width:2px,color:#fff;
    classDef security fill:#008AD7,stroke:#fff,stroke-width:2px,color:#fff;

    %% Fontes de Dados
    subgraph Origem ["📡 Fontes de Dados (Telecom)"]
        A1[Logs de Antenas / ERBs]
        A2[CDRs - Bilhetagem]
    end

    %% Camada de Segurança
    subgraph Seguranca ["🔐 Governança & Segurança (Azure)"]
        KV[Azure Key Vault]:::security
        IAM[Managed Identities]:::security
    end

    %% Infraestrutura provisionada pelo Terraform
    subgraph Cloud ["☁️ Azure Cloud (Provisionado via Terraform)"]
        direction LR
        
        %% Data Lake (Medallion Architecture)
        subgraph ADLS ["🪣 Azure Data Lake Storage Gen2"]
            B[🥉 Bronze\n(Dados Brutos)]:::storage
            S[🥈 Silver\n(Limpos / Delta Lake)]:::storage
            G[🥇 Gold\n(Agregados / Negócio)]:::storage
        end

        %% Processamento
        subgraph Databricks ["🧠 Processamento Distribuído"]
            SP1[PySpark Job\nLimpeza & Filtro]:::compute
            SP2[PySpark Job\nAgregação & Regras]:::compute
        end
    end

    %% Fluxo de Dados
    Origem -->|Ingestão| B
    B -->|Leitura| SP1
    SP1 -->|Gravação Delta| S
    S -->|Leitura| SP2
    SP2 -->|Gravação Delta| G

    %% Relacionamento de Segurança
    KV -.->|Injeta Segredos| Databricks
    IAM -.->|Autoriza Acesso| ADLS