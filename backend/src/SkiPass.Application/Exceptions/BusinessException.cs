namespace SkiPass.Application.Exceptions;

/// <summary>
/// Krsenje poslovnog pravila (nedozvoljen prelaz statusa, zauzet termin, neispravan preduslov).
/// Mapira se na HTTP 409.
/// </summary>
public class BusinessException : Exception
{
    public BusinessException(string message) : base(message)
    {
    }
}
