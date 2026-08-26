using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SkiPass.Application.DTOs.Users;
using SkiPass.Application.Exceptions;
using SkiPass.Application.Services.Interfaces;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Enums;
using SkiPass.Domain.Interfaces;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Services;

public class UserService
    : CrudServiceBase<User, UserDto, UserCreateDto, UserUpdateDto, UserSearchDto>, IUserService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IUnitOfWork _unitOfWork;

    public UserService(
        ApplicationDbContext context,
        UserManager<ApplicationUser> userManager,
        IUnitOfWork unitOfWork,
        ILogger<UserService> logger)
        : base(context, logger)
    {
        _userManager = userManager;
        _unitOfWork = unitOfWork;
    }

    protected override string EntityName => "Korisnik";

    protected override IQueryable<User> BaseQuery() =>
        Context.UserProfiles
            .Include(u => u.City)
            .Include(u => u.IdentityUser)
            .Include(u => u.Orders);

    protected override IQueryable<User> ApplyFilters(IQueryable<User> query, UserSearchDto request)
    {
        if (!string.IsNullOrWhiteSpace(request.Query))
        {
            var term = request.Query.Trim();
            query = query.Where(u =>
                u.FirstName.Contains(term) ||
                u.LastName.Contains(term) ||
                u.Email.Contains(term) ||
                (u.IdentityUser != null && u.IdentityUser.UserName != null && u.IdentityUser.UserName.Contains(term)));
        }

        if (!string.IsNullOrWhiteSpace(request.Role))
        {
            var role = ParseEnum<UserRole>(request.Role, nameof(request.Role));
            query = query.Where(u => u.Role == role);
        }

        if (request.IsActive.HasValue)
        {
            query = query.Where(u => u.IsActive == request.IsActive.Value);
        }

        if (request.CityId.HasValue)
        {
            query = query.Where(u => u.CityId == request.CityId.Value);
        }

        return query;
    }

    protected override IQueryable<User> ApplyDefaultSort(IQueryable<User> query) =>
        query.OrderBy(u => u.LastName).ThenBy(u => u.FirstName);

    protected override IQueryable<User>? ApplySort(IQueryable<User> query, string sortBy, bool descending) =>
        sortBy.ToLowerInvariant() switch
        {
            "firstname" => descending ? query.OrderByDescending(u => u.FirstName) : query.OrderBy(u => u.FirstName),
            "lastname" => descending ? query.OrderByDescending(u => u.LastName) : query.OrderBy(u => u.LastName),
            "email" => descending ? query.OrderByDescending(u => u.Email) : query.OrderBy(u => u.Email),
            "createdat" => descending ? query.OrderByDescending(u => u.CreatedAt) : query.OrderBy(u => u.CreatedAt),
            "lastloginat" => descending ? query.OrderByDescending(u => u.LastLoginAt) : query.OrderBy(u => u.LastLoginAt),
            _ => null
        };

    protected override UserDto MapToDto(User e) => new()
    {
        Id = e.Id,
        Username = e.IdentityUser?.UserName ?? string.Empty,
        FirstName = e.FirstName,
        LastName = e.LastName,
        FullName = $"{e.FirstName} {e.LastName}",
        Email = e.Email,
        Phone = e.Phone,
        BirthDate = e.BirthDate,
        ProfileImageUrl = e.ProfileImageUrl,
        Role = e.Role.ToString(),
        IsActive = e.IsActive,
        LastLoginAt = e.LastLoginAt,
        CityId = e.CityId,
        CityName = e.City?.Name,
        CreatedAt = e.CreatedAt,
        OrderCount = e.Orders.Count(o => !o.IsDeleted)
    };

    public async Task<UserDto> GetProfileAsync(int userId, CancellationToken cancellationToken = default) =>
        await GetByIdAsync(userId, cancellationToken);

    public async Task<UserDto> UpdateProfileAsync(int userId, UserProfileUpdateDto dto, CancellationToken cancellationToken = default)
    {
        var entity = await Context.UserProfiles.FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, userId);

        await EnsureEmailAvailableAsync(entity.Id, dto.Email, cancellationToken);
        await EnsureCityExistsAsync(dto.CityId, cancellationToken);

        entity.FirstName = dto.FirstName.Trim();
        entity.LastName = dto.LastName.Trim();
        entity.Email = dto.Email.Trim();
        entity.Phone = dto.Phone?.Trim();
        entity.BirthDate = dto.BirthDate;
        entity.ProfileImageUrl = dto.ProfileImageUrl?.Trim();
        entity.CityId = dto.CityId;

        await SyncIdentityContactAsync(entity, cancellationToken);
        await Context.SaveChangesAsync(cancellationToken);

        Logger.LogInformation("Korisnik {UserId} je azurirao vlastiti profil.", userId);
        return await GetByIdAsync(userId, cancellationToken);
    }

    /// <summary>
    /// Kreiranje korisnika obuhvata i Identity zapis i poslovni profil,
    /// pa se oba upisa izvrsavaju unutar jedne transakcije.
    /// </summary>
    public override async Task<UserDto> CreateAsync(UserCreateDto dto, CancellationToken cancellationToken = default)
    {
        var role = ParseEnum<UserRole>(dto.Role, nameof(dto.Role));

        if (await _userManager.FindByNameAsync(dto.Username) is not null)
        {
            throw new ValidationException(nameof(dto.Username), "Korisnicko ime je vec zauzeto.");
        }

        await EnsureEmailAvailableAsync(0, dto.Email, cancellationToken);
        await EnsureCityExistsAsync(dto.CityId, cancellationToken);

        await _unitOfWork.BeginTransactionAsync(cancellationToken);
        try
        {
            var identityUser = new ApplicationUser
            {
                UserName = dto.Username,
                Email = dto.Email,
                PhoneNumber = dto.Phone
            };

            var result = await _userManager.CreateAsync(identityUser, dto.Password);
            if (!result.Succeeded)
            {
                throw new ValidationException(nameof(dto.Password), string.Join(" ", result.Errors.Select(e => e.Description)));
            }

            await _userManager.AddToRoleAsync(identityUser, role.ToString());

            var entity = new User
            {
                IdentityUserId = identityUser.Id,
                FirstName = dto.FirstName.Trim(),
                LastName = dto.LastName.Trim(),
                Email = dto.Email.Trim(),
                Phone = dto.Phone?.Trim(),
                BirthDate = dto.BirthDate,
                ProfileImageUrl = dto.ProfileImageUrl?.Trim(),
                CityId = dto.CityId,
                Role = role,
                IsActive = dto.IsActive
            };

            Context.UserProfiles.Add(entity);
            await Context.SaveChangesAsync(cancellationToken);
            await _unitOfWork.CommitTransactionAsync(cancellationToken);

            Logger.LogInformation("Kreiran korisnik {UserId} sa rolom {Role}.", entity.Id, role);
            return await GetByIdAsync(entity.Id, cancellationToken);
        }
        catch
        {
            await _unitOfWork.RollbackTransactionAsync(cancellationToken);
            throw;
        }
    }

    protected override Task MapCreateAsync(User entity, UserCreateDto dto, CancellationToken cancellationToken) =>
        throw new NotSupportedException("Kreiranje korisnika se obavlja kroz CreateAsync zbog rada sa Identity zapisom.");

    protected override async Task MapUpdateAsync(User entity, UserUpdateDto dto, CancellationToken cancellationToken)
    {
        var role = ParseEnum<UserRole>(dto.Role, nameof(dto.Role));

        await EnsureEmailAvailableAsync(entity.Id, dto.Email, cancellationToken);
        await EnsureCityExistsAsync(dto.CityId, cancellationToken);

        var roleChanged = entity.Role != role;

        entity.FirstName = dto.FirstName.Trim();
        entity.LastName = dto.LastName.Trim();
        entity.Email = dto.Email.Trim();
        entity.Phone = dto.Phone?.Trim();
        entity.BirthDate = dto.BirthDate;
        entity.ProfileImageUrl = dto.ProfileImageUrl?.Trim();
        entity.CityId = dto.CityId;
        entity.Role = role;
        entity.IsActive = dto.IsActive;

        var identityUser = await FindIdentityUserAsync(entity, cancellationToken);
        if (identityUser is null)
        {
            return;
        }

        identityUser.Email = entity.Email;
        identityUser.PhoneNumber = entity.Phone;
        await _userManager.UpdateAsync(identityUser);

        if (roleChanged)
        {
            var currentRoles = await _userManager.GetRolesAsync(identityUser);
            await _userManager.RemoveFromRolesAsync(identityUser, currentRoles);
            await _userManager.AddToRoleAsync(identityUser, role.ToString());
            await _userManager.UpdateSecurityStampAsync(identityUser);
        }

        // Lozinka se mijenja samo ako je administrator popunio polje za novu lozinku.
        if (!string.IsNullOrWhiteSpace(dto.NewPassword))
        {
            var token = await _userManager.GeneratePasswordResetTokenAsync(identityUser);
            var result = await _userManager.ResetPasswordAsync(identityUser, token, dto.NewPassword);
            if (!result.Succeeded)
            {
                throw new ValidationException(nameof(dto.NewPassword), string.Join(" ", result.Errors.Select(e => e.Description)));
            }
        }
    }

    protected override async Task EnsureCanDeleteAsync(User entity, CancellationToken cancellationToken)
    {
        var orderCount = await Context.SkiPassOrders.CountAsync(o => o.UserId == entity.Id && !o.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Narudzbe ski pass karata", orderCount);

        var incidentCount = await Context.Incidents.CountAsync(i => i.ReportedByUserId == entity.Id && !i.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Prijavljeni incidenti", incidentCount);

        var purchaseCount = await Context.BenefitPurchases.CountAsync(p => p.UserId == entity.Id && !p.IsDeleted, cancellationToken);
        EnsureNotReferenced(EntityName, "Kupljene pogodnosti", purchaseCount);
    }

    /// <summary>Brisanjem profila se onemogucava i prijava, jer Identity zapis ostaje zakljucan.</summary>
    public override async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await Context.UserProfiles.FirstOrDefaultAsync(u => u.Id == id && !u.IsDeleted, cancellationToken)
            ?? throw NotFoundException.For(EntityName, id);

        await EnsureCanDeleteAsync(entity, cancellationToken);

        entity.IsDeleted = true;
        entity.IsActive = false;

        var identityUser = await FindIdentityUserAsync(entity, cancellationToken);
        if (identityUser is not null)
        {
            await _userManager.SetLockoutEnabledAsync(identityUser, true);
            await _userManager.SetLockoutEndDateAsync(identityUser, DateTimeOffset.MaxValue);
            await _userManager.UpdateSecurityStampAsync(identityUser);
        }

        await Context.SaveChangesAsync(cancellationToken);
        Logger.LogInformation("Obrisan korisnik {UserId}.", id);
    }

    private Task<ApplicationUser?> FindIdentityUserAsync(User entity, CancellationToken cancellationToken) =>
        entity.IdentityUserId is null
            ? Task.FromResult<ApplicationUser?>(null)
            : Context.Set<ApplicationUser>().FirstOrDefaultAsync(u => u.Id == entity.IdentityUserId.Value, cancellationToken);

    private async Task SyncIdentityContactAsync(User entity, CancellationToken cancellationToken)
    {
        var identityUser = await FindIdentityUserAsync(entity, cancellationToken);
        if (identityUser is null)
        {
            return;
        }

        identityUser.Email = entity.Email;
        identityUser.PhoneNumber = entity.Phone;
    }

    private async Task EnsureEmailAvailableAsync(int userId, string email, CancellationToken cancellationToken)
    {
        var taken = await Context.UserProfiles
            .AnyAsync(u => u.Id != userId && !u.IsDeleted && u.Email == email, cancellationToken);

        if (taken)
        {
            throw new ValidationException(nameof(UserUpdateDto.Email), "E-mail adresa je vec registrovana na drugog korisnika.");
        }
    }

    private async Task EnsureCityExistsAsync(int? cityId, CancellationToken cancellationToken)
    {
        if (cityId is null)
        {
            return;
        }

        var exists = await Context.Cities.AnyAsync(c => c.Id == cityId.Value && !c.IsDeleted, cancellationToken);
        if (!exists)
        {
            throw new ValidationException(nameof(UserUpdateDto.CityId), "Odabrani grad ne postoji.");
        }
    }
}
