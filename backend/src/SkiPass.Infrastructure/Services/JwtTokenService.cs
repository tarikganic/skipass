using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using SkiPass.Application.Services.Interfaces;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Konfiguracija se cita jednom u konstruktoru, a ne pri svakom izdavanju tokena.
/// </summary>
public class JwtTokenService : IJwtTokenService
{
    /// <summary>
    /// Claim koji nosi sigurnosni pecat korisnika. Rotacijom pecata na serveru
    /// svi ranije izdati tokeni postaju nevazeci.
    /// </summary>
    public const string SecurityStampClaimType = "security_stamp";

    private readonly string _key;
    private readonly string _issuer;
    private readonly string _audience;
    private readonly int _expiryMinutes;

    public JwtTokenService(IConfiguration configuration)
    {
        _key = configuration["Jwt:Key"]
            ?? throw new InvalidOperationException("Jwt:Key nije konfigurisan.");
        _issuer = configuration["Jwt:Issuer"]
            ?? throw new InvalidOperationException("Jwt:Issuer nije konfigurisan.");
        _audience = configuration["Jwt:Audience"]
            ?? throw new InvalidOperationException("Jwt:Audience nije konfigurisan.");
        _expiryMinutes = configuration.GetValue("Jwt:ExpiryMinutes", 480);
    }

    public (string Token, DateTime ExpiresAt) CreateToken(int userId, string username, string email, string role, string securityStamp)
    {
        var expiresAt = DateTime.UtcNow.AddMinutes(_expiryMinutes);

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(ClaimTypes.Name, username),
            new(ClaimTypes.Email, email),
            new(ClaimTypes.Role, role),
            new(SecurityStampClaimType, securityStamp),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var credentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_key)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _issuer,
            audience: _audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expiresAt,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }
}
