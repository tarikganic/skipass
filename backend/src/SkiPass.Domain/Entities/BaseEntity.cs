namespace SkiPass.Domain.Entities;

/// <summary>
/// Zajednicka osnova za sve entitete: identitet, audit vremena i soft delete oznaka.
/// </summary>
public abstract class BaseEntity
{
    public int Id { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    public bool IsDeleted { get; set; }
}
