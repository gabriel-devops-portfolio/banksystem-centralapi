# BankSystem Central API

Central registry and coordination service for bank microservices.

## Architecture
- ASP.NET Core 3.1 Web API
- Entity Framework Core with SQL Server
- AWS RDS with IAM authentication
- RESTful API for bank registration and discovery

## Features
- Bank registration and management
- Service discovery for bank microservices
- Central authentication coordination
- Inter-bank transaction routing
- Bank status monitoring

## Getting Started

### Prerequisites
- .NET Core 3.1 SDK
- Docker
- AWS CLI configured

### Local Development

```bash
# Restore dependencies
dotnet restore src/CentralApi.sln

# Run locally
cd src/CentralApi
dotnet run

# API will be available at
# http://localhost:5000
```

### Docker Build

```bash
# Build from repository root
docker build -t centralapi:latest .

# Run locally
docker run -p 5000:5000 \
  -e ConnectionStrings__DefaultConnection="..." \
  -e ASPNETCORE_ENVIRONMENT=Development \
  centralapi:latest
```

### Deploy to EKS

```bash
# Apply Kubernetes manifests
kubectl apply -f kubernetes/

# Check deployment status
kubectl get pods -n banksystem -l app=centralapi
kubectl logs -f deployment/centralapi -n banksystem

# Check service endpoint
kubectl get svc centralapi-service -n banksystem
```

## Configuration

### Environment Variables
- `RdsAuthentication__UseIamAuthentication` - Enable IAM auth (true/false)
- `RdsAuthentication__RdsEndpoint` - RDS endpoint
- `RdsAuthentication__DbUser` - Database username (centralapi_app)
- `RdsAuthentication__AwsRegion` - AWS region
- `RdsAuthentication__FallbackPassword` - Password for fallback

### Database Setup
```bash
# Run migrations
cd src/CentralApi
dotnet ef database update
```

## Project Structure

```
banksystem-centralapi/
├── Dockerfile              # Multi-stage Docker build
├── README.md              # This file
├── kubernetes/            # Kubernetes manifests
│   ├── deployment.yaml    # Deployment, Service, ServiceAccount
│   └── ingress.yaml       # ALB Ingress configuration
├── terraform/             # Infrastructure as Code
├── docs/                  # Documentation
├── tests/                 # Unit tests
│   └── CentralApi.Services.Tests/
└── src/                   # Source code
    ├── CentralApi.sln
    ├── BankSystem.Common/
    ├── CentralApi.Models/
    ├── CentralApi.Data/
    ├── CentralApi.Services/
    ├── CentralApi.Services.Models/
    └── CentralApi/
```

## API Endpoints

### Bank Management
- `GET /api/banks` - List all registered banks
- `GET /api/banks/{id}` - Get bank details
- `POST /api/banks` - Register new bank
- `PUT /api/banks/{id}` - Update bank information
- `DELETE /api/banks/{id}` - Deregister bank

### Service Discovery
- `GET /api/banks/lookup/{bankCode}` - Lookup bank by code
- `GET /api/banks/status` - Get all bank statuses

### Health & Monitoring
- `GET /health` - Health check endpoint
- `GET /api/health/detailed` - Detailed health information

## API Authentication

The Central API uses:
- JWT tokens for authentication
- API keys for inter-service communication
- Mutual TLS for bank-to-bank communication

```bash
# Example API call
curl -X GET "https://centralapi.example.com/api/banks" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Testing

```bash
# Run unit tests
dotnet test tests/CentralApi.Services.Tests/

# Run with coverage
dotnet test tests/CentralApi.Services.Tests/ /p:CollectCoverage=true
```

## CI/CD

GitHub Actions workflow automatically:
1. Runs unit tests
2. Builds Docker image
3. Pushes to Amazon ECR
4. Deploys to EKS cluster
5. Runs integration tests

## Monitoring & Logging

- **Health Checks**: Kubernetes liveness/readiness probes
- **Logging**: Structured logging with Serilog to CloudWatch
- **Metrics**: Prometheus metrics endpoint at `/metrics`
- **Tracing**: AWS X-Ray integration

## Security

- Non-root container execution
- IAM-based RDS authentication
- Secrets managed via Kubernetes Secrets
- TLS/HTTPS enforced via ALB
- Network policies for pod communication

## Development

### Running Tests
```bash
cd tests/CentralApi.Services.Tests
dotnet test --verbosity normal
```

### Database Migrations
```bash
# Add new migration
cd src/CentralApi.Data
dotnet ef migrations add MigrationName --startup-project ../CentralApi

# Apply migrations
dotnet ef database update --startup-project ../CentralApi
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Verify RDS endpoint is correct
   - Check IAM authentication permissions
   - Verify security group rules

2. **Pod CrashLoopBackOff**
   - Check logs: `kubectl logs <pod-name> -n banksystem`
   - Verify secrets are correctly mounted
   - Check database connectivity

3. **Health Check Failures**
   - Verify `/health` endpoint is accessible
   - Check database connection health
   - Review application logs

## License

MIT
