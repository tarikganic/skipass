FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY src/SkiPass.Contracts/SkiPass.Contracts.csproj src/SkiPass.Contracts/
COPY src/SkiPass.Worker/SkiPass.Worker.csproj src/SkiPass.Worker/
COPY Directory.Build.props .
RUN dotnet restore src/SkiPass.Worker/SkiPass.Worker.csproj

COPY src/SkiPass.Contracts/ src/SkiPass.Contracts/
COPY src/SkiPass.Worker/ src/SkiPass.Worker/
RUN dotnet publish src/SkiPass.Worker/SkiPass.Worker.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "SkiPass.Worker.dll"]
