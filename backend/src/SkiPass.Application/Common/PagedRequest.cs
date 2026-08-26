using System.ComponentModel.DataAnnotations;

namespace SkiPass.Application.Common;

/// <summary>
/// Osnova za sve pretrage. Paginacija je obavezna na svakom list endpointu,
/// a velicina stranice je ogranicena da bi se sprijecilo preopterecenje servera.
/// </summary>
public abstract class PagedRequest
{
    public const int MaxPageSize = 100;
    public const int DefaultPageSize = 20;

    private int _page = 1;
    private int _pageSize = DefaultPageSize;

    [Range(1, int.MaxValue, ErrorMessage = "Broj stranice mora biti veci od 0.")]
    public int Page
    {
        get => _page;
        set => _page = value < 1 ? 1 : value;
    }

    [Range(1, MaxPageSize, ErrorMessage = "Velicina stranice mora biti izmedju 1 i 100.")]
    public int PageSize
    {
        get => _pageSize;
        set => _pageSize = value switch
        {
            < 1 => DefaultPageSize,
            > MaxPageSize => MaxPageSize,
            _ => value
        };
    }

    /// <summary>Naziv polja po kojem se sortira. Dozvoljene vrijednosti definise svaki servis.</summary>
    public string? SortBy { get; set; }

    public bool SortDescending { get; set; }

    /// <summary>Ukljucuje i soft-deleted zapise. Dostupno samo administratorima.</summary>
    public bool IncludeDeleted { get; set; }
}
