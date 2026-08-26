namespace SkiPass.Application.Exceptions;

/// <summary>
/// Zapis se ne moze obrisati jer ga koriste drugi entiteti.
/// Poruka korisniku eksplicitno navodi koji zapisi sprjecavaju brisanje.
/// </summary>
public class ReferencedEntityException : BusinessException
{
    public ReferencedEntityException(string entityName, string usedBy, int count)
        : base($"{entityName} se ne moze obrisati jer je koristi {count} zapisa u evidenciji \"{usedBy}\". Prvo uklonite ili prevezite te zapise.")
    {
    }
}
