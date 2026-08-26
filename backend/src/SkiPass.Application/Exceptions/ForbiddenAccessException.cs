namespace SkiPass.Application.Exceptions;

/// <summary>Korisnik je autentifikovan, ali nema pravo nad trazenim zapisom. Mapira se na HTTP 403.</summary>
public class ForbiddenAccessException : Exception
{
    public ForbiddenAccessException(string message = "Nemate ovlastenje za ovu akciju.") : base(message)
    {
    }
}
