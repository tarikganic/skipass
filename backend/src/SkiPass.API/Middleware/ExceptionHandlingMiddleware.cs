using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using SkiPass.API.Contracts;
using SkiPass.Application.Exceptions;
using ValidationException = SkiPass.Application.Exceptions.ValidationException;

namespace SkiPass.API.Middleware;

/// <summary>
/// Mapira custom tipove izuzetaka na HTTP statuse i vraca standardizovan odgovor.
/// Detalji greske se logiraju na serveru, a klijent dobija samo razumljivu poruku.
/// </summary>
public class ExceptionHandlingMiddleware
{
    private static readonly JsonSerializerOptions SerializerOptions = new(JsonSerializerDefaults.Web);

    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception exception)
        {
            await HandleAsync(context, exception);
        }
    }

    private async Task HandleAsync(HttpContext context, Exception exception)
    {
        var traceId = context.TraceIdentifier;

        var (statusCode, response) = exception switch
        {
            ValidationException validation => (
                HttpStatusCode.BadRequest,
                new ApiErrorResponse
                {
                    Message = validation.Message,
                    Errors = validation.Errors.ToDictionary(kvp => kvp.Key, kvp => kvp.Value),
                    TraceId = traceId
                }),

            NotFoundException notFound => (
                HttpStatusCode.NotFound,
                new ApiErrorResponse { Message = notFound.Message, TraceId = traceId }),

            ForbiddenAccessException forbidden => (
                HttpStatusCode.Forbidden,
                new ApiErrorResponse { Message = forbidden.Message, TraceId = traceId }),

            BusinessException business => (
                HttpStatusCode.Conflict,
                new ApiErrorResponse { Message = business.Message, TraceId = traceId }),

            DbUpdateException => (
                HttpStatusCode.Conflict,
                new ApiErrorResponse
                {
                    Message = "Podatke nije moguce sacuvati jer bi se narusio integritet vec postojecih zapisa.",
                    TraceId = traceId
                }),

            OperationCanceledException => (
                HttpStatusCode.BadRequest,
                new ApiErrorResponse { Message = "Zahtjev je prekinut prije zavrsetka obrade.", TraceId = traceId }),

            _ => (
                HttpStatusCode.InternalServerError,
                new ApiErrorResponse
                {
                    Message = "Doslo je do neocekivane greske. Molimo pokusajte ponovo ili kontaktirajte podrsku.",
                    TraceId = traceId
                })
        };

        LogException(context, exception, statusCode, traceId);

        if (context.Response.HasStarted)
        {
            _logger.LogWarning("Odgovor je vec zapocet, greska {TraceId} se ne moze prikazati klijentu.", traceId);
            return;
        }

        context.Response.Clear();
        context.Response.StatusCode = (int)statusCode;
        context.Response.ContentType = "application/json";

        await context.Response.WriteAsync(JsonSerializer.Serialize(response, SerializerOptions));
    }

    private void LogException(HttpContext context, Exception exception, HttpStatusCode statusCode, string traceId)
    {
        const string template =
            "Zahtjev {Method} {Path} zavrsen sa statusom {StatusCode}. TraceId: {TraceId}. Korisnik: {UserName}.";

        var userName = context.User.Identity?.Name ?? "anoniman";

        if (statusCode == HttpStatusCode.InternalServerError)
        {
            _logger.LogError(
                exception, template, context.Request.Method, context.Request.Path,
                (int)statusCode, traceId, userName);
        }
        else
        {
            _logger.LogWarning(
                exception, template, context.Request.Method, context.Request.Path,
                (int)statusCode, traceId, userName);
        }
    }
}
