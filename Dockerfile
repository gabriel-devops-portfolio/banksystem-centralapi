# =========================
# 1. Build stage
# =========================
FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src

# Copy solution and csproj files for better restore caching
COPY src/CentralApi.sln ./

# Common projects
COPY src/BankSystem.Common/*.csproj BankSystem.Common/

# CentralApi projects
COPY src/CentralApi.Models/*.csproj CentralApi.Models/
COPY src/CentralApi.Data/*.csproj CentralApi.Data/
COPY src/CentralApi.Services/*.csproj CentralApi.Services/
COPY src/CentralApi.Services.Models/*.csproj CentralApi.Services.Models/
COPY src/CentralApi/*.csproj CentralApi/

# Restore dependencies
RUN dotnet restore CentralApi/CentralApi.csproj

# Copy all source code
COPY src/ .

# Build and publish
WORKDIR /src/CentralApi
RUN dotnet publish -c Release -o /app/publish --no-restore

# =========================
# 2. Runtime stage
# =========================
FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS runtime

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy published output from build stage
COPY --from=build /app/publish .

# Set ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Configure ASP.NET Core to listen on port 5000
ENV ASPNETCORE_URLS=http://+:5000 \
 ASPNETCORE_ENVIRONMENT=Production \
 DOTNET_RUNNING_IN_CONTAINER=true \
 DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Expose HTTP port
EXPOSE 5000

# Health check (adjust path if you have a dedicated health endpoint)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
 CMD curl -f http://localhost:5000/health || exit 1

# Run the application
ENTRYPOINT ["dotnet", "CentralApi.dll"]
