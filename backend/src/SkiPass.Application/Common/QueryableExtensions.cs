
namespace SkiPass.Application.Common;

public static class QueryableExtensions
{
    /// <summary>
    /// Primjenjuje paginaciju na nivou baze i vraca ukupan broj zapisa u jednom prolazu.
    /// Projekcija se izvrsava prije materijalizacije kako bi se izbjegao N+1 problem.
    /// </summary>
    public static PagedResult<T> ToPagedResult<T>(this List<T> items, int totalCount, PagedRequest request) => new()
    {
        Items = items,
        TotalCount = totalCount,
        Page = request.Page,
        PageSize = request.PageSize
    };
}
