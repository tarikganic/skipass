namespace SkiPass.Application.Exceptions;

/// <summary>Trazeni zapis ne postoji ili je obrisan. Mapira se na HTTP 404.</summary>
public class NotFoundException : Exception
{
    public NotFoundException(string message) : base(message)
    {
    }

    public static NotFoundException For(string entityName, int id) =>
        new($"{entityName} sa identifikatorom {id} nije pronadjen.");
}
