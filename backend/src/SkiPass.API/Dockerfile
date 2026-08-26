FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY src/SkiPass.Domain/SkiPass.Domain.csproj src/SkiPass.Domain/
COPY src/SkiPass.Contracts/SkiPass.Contracts.csproj src/SkiPass.Contracts/
COPY src/SkiPass.Application/SkiPass.Application.csproj src/SkiPass.Application/
COPY src/SkiPass.Infrastructure/SkiPass.Infrastructure.csproj src/SkiPass.Infrastructure/
COPY src/SkiPass.API/SkiPass.API.csproj src/SkiPass.API/
COPY Directory.Build.props .
RUN dotnet restore src/SkiPass.API/SkiPass.API.csproj

COPY . .
RUN dotnet publish src/SkiPass.API/SkiPass.API.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 5000
ENTRYPOINT ["dotnet", "SkiPass.API.dll"]
