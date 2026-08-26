namespace SkiPass.Application.Exceptions;

/// <summary>
/// Serverska validacija korisnickog unosa. Mapira se na HTTP 400 sa listom gresaka po polju,
/// u istom formatu koji vraca i automatska model-state validacija.
/// </summary>
public class ValidationException : Exception
{
    public ValidationException(string field, string message)
        : this(new Dictionary<string, string[]> { [field] = [message] })
    {
    }

    public ValidationException(IDictionary<string, string[]> errors)
        : base("Molimo ispravite oznacena polja.")
    {
        Errors = new Dictionary<string, string[]>(errors);
    }

    public IReadOnlyDictionary<string, string[]> Errors { get; }
}
