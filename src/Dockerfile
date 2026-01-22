# Build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ZavaStorefront.csproj .
RUN dotnet restore

# Copy remaining source code
COPY . .

# Build the application
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app

# Copy published output from publish stage
COPY --from=publish /app/publish .

# Expose port 8080 (Azure App Service uses port 8080 by default for Linux containers)
EXPOSE 8080

# Set environment variable for port
ENV ASPNETCORE_URLS=http://+:8080

# Run the application
ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]
