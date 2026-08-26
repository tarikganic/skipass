using System.Security.Cryptography;

namespace SkiPass.Infrastructure.Services;

/// <summary>
/// Generise QR kodove i brojeve narudzbi kriptografski sigurnim generatorom.
/// System.Random nije prihvatljiv za vrijednosti koje sluze kao dokaz kupovine.
/// </summary>
public static class SecureCodeGenerator
{
    private const string Alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

    /// <summary>Sadrzaj QR koda karte, npr. SP-7K2M9QX4TB1ZC8VF.</summary>
    public static string CreateQrCode() => $"SP-{CreateToken(16)}";

    /// <summary>Broj narudzbe u formatu SP-20260824-9QX4TB1Z.</summary>
    public static string CreateOrderNumber(DateTime utcNow) =>
        $"SP-{utcNow:yyyyMMdd}-{CreateToken(8)}";

    private static string CreateToken(int length)
    {
        var buffer = new char[length];
        for (var i = 0; i < length; i++)
        {
            buffer[i] = Alphabet[RandomNumberGenerator.GetInt32(Alphabet.Length)];
        }

        return new string(buffer);
    }
}
