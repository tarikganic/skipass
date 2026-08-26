using Microsoft.Extensions.DependencyInjection;

namespace SkiPass.Application;

public static class DependencyInjection
{
    /// <summary>
    /// Registruje servise aplikacijskog sloja. Implementacije se nalaze u Infrastructure sloju,
    /// pa ovaj sloj trenutno registruje samo validacijske i mapiranje pomocne komponente.
    /// </summary>
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        return services;
    }
}
