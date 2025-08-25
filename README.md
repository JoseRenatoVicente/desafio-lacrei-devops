# Template CI/CD Node.js AWS ECS

Aplicação de exemplo para CI/CD moderno usando Node.js, Docker, AWS ECS Fargate e GitHub Actions.

## 🚀 Visão Geral

- API Node.js simples com rota `/status`.
- Deploy automatizado para ambientes **staging** e **produção** na AWS.
- Pipeline CI/CD robusto com validações, testes, build, scan e deploy.
- Segurança reforçada (least privilege, secrets, distroless, root FS readonly, drop capabilities).
- Rollback automatizado via workflow.
- Observabilidade: logs no CloudWatch, healthcheck, integração CloudWatch.

## 🔄 Fluxo do Pipeline CI/CD

```mermaid
flowchart TD
	subgraph Entrada
		A1[Push_PR]
		A2[Push_develop]
		A3[Push_main]
	end
	A1 --> B1[Lint]
	A2 --> B2[Lint]
	A3 --> B3[Lint]
	B1 --> C1[Testes]
	B2 --> C2[Testes]
	B3 --> C3[Testes]
	C1 --> D1[Build]
	C2 --> D2[Build]
	C3 --> D3[Build]
	D1 --> E1[Security_Scan]
	D2 --> E2[Security_Scan]
	D3 --> E3[Security_Scan]
	E1 --> F1[Fim_PR_sem_deploy]
	E2 --> G2[Build_Docker]
	E3 --> G3[Build_Docker]
	G2 --> H2[Push_Docker_ECR]
	G3 --> H3[Push_Docker_ECR]
	H2 --> I2[Deploy_ECS_staging]
	H3 --> I3[Deploy_ECS_prod]
	I2 --> J2[Obter_URL_staging]
	I3 --> J3[Obter_URL_prod]
	J2 --> K2[Testes_pos_deploy_staging]
	J3 --> K3[Testes_pos_deploy_prod]
	K2 --> L2[Fim_staging]
	K3 --> L3[Criar_Release_prod]
	L3 --> M3[Fim_prod]
```

## 🗺️ Arquitetura e Fluxo AWS

```mermaid
graph TD
	H[Usuario] --> A[API_Gateway_HTTP]
	A -- VPC_Link --> B[NLB]
	B -- Target_Group --> C[ECS_Service]
	C -- Task --> D[ECS_Fargate_Container]
	D -- Logs --> E[CloudWatch_Logs]
	C -- Service_Discovery --> F[Service_Discovery]
	B -- VPC_Subnets --> G[VPC_Subnets]
```

# Infraestrutura com Terraform

Este projeto possui scripts em Terraform para construir toda a infraestrutura necessária na AWS.

## Como utilizar

1. Ajuste as variáveis de acordo com seu ambiente nos arquivos:
   - `terraform/terraform.tfvars` (produção)
   - `terraform/terraform.tfvars.staging` (staging)
2. Acesse a pasta do Terraform:
   ```powershell
   cd .\terraform\
   ```
3. Execute o script de deploy:
   ```powershell
   .\deploy.ps1
   ```

O script irá aplicar a infraestrutura conforme as configurações definidas.

## 📦 Estrutura

```
├── src/                # Código da aplicação
├── tests/              # Testes automatizados
├── Dockerfile          # Build seguro (distroless)
├── .github/
│   ├── workflows/      # CI/CD e rollback
│   └── .aws/           # Task definition ECS
└── README.md           # Documentação
```

## 🛠️ Como rodar local

```bash
npm install
npm run test
npm start
```

## 🐳 Build e execução com Docker

```bash
docker build -t template-ci-cd .
docker run -p 3000:3000 template-ci-cd
```

## 🔑 Variáveis de Ambiente e Secrets Necessários

### GitHub Secrets

- `AWS_ACCESS_KEY_ID`: Chave de acesso AWS IAM
- `AWS_SECRET_ACCESS_KEY`: Chave secreta AWS IAM

### GitHub Actions Vars

- `AWS_ACCOUNT_ID`: 038462749081
- `AWS_REGION`: us-east-1
- `ECS_CLUSTER_NAME`: template-ci-cd-cluster-prod
- `ECS_SECURITY_GROUPS`: sg-03e4ec7b925fb9e59
- `ECS_SERVICE_NAME_PREFIX`: template-ci-cd-service-prod
- `ECS_SUBNETS`: subnet-049a6c7f1e04c6b05,subnet-0cbfede9311

> Configure esses valores em Settings > Secrets and variables > Actions no repositório do GitHub.

## ☁️ Deploy na AWS (ECS Fargate)

- Pipeline GitHub Actions faz build, push e deploy automático.
- Task definition: `.github/.aws/task-definition.json`
- Secrets e variáveis: GitHub Secrets e AWS Secrets Manager.

## 🔄 Rollback

- Use o workflow `rollback.yml` no GitHub Actions.
- Informe a tag da imagem Docker desejada para reverter o serviço ECS.

## 🔒 Segurança

- Usuário não-root, root filesystem readonly, drop capabilities.
- Políticas IAM mínimas para tasks.
- Secrets nunca hardcoded.
- HTTPS via API Gateway/ALB.

## 📈 Observabilidade

- Logs enviados ao CloudWatch.
- Healthcheck configurado no ECS.

## 📝 Checklist rápido

- [x] Deploy funcional (staging/prod)
- [x] Docker + GitHub Actions + AWS
- [x] Pipeline CI/CD completo
- [x] Segurança aplicada
- [x] Observabilidade
- [x] Rollback documentado
- [x] Documentação clara

## 🧯 Rollback manual

- Via workflow `rollback.yml` ou alterando tag da imagem no ECS.

---
