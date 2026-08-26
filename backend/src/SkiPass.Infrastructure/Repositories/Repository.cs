using Microsoft.EntityFrameworkCore;
using SkiPass.Domain.Entities;
using SkiPass.Domain.Interfaces;
using SkiPass.Infrastructure.Data;

namespace SkiPass.Infrastructure.Repositories;

public class Repository<T> : IRepository<T> where T : BaseEntity
{
    private readonly ApplicationDbContext _context;
    private readonly DbSet<T> _dbSet;

    public Repository(ApplicationDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public Task<T?> GetByIdAsync(int id, CancellationToken cancellationToken = default) =>
        _dbSet.FirstOrDefaultAsync(e => e.Id == id, cancellationToken);

    public IQueryable<T> GetQueryable() => _dbSet.AsQueryable();

    public async Task<T> AddAsync(T entity, CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(entity, cancellationToken);
        return entity;
    }

    public Task UpdateAsync(T entity, CancellationToken cancellationToken = default)
    {
        _dbSet.Update(entity);
        return Task.CompletedTask;
    }

    public Task DeleteAsync(T entity, CancellationToken cancellationToken = default)
    {
        _dbSet.Remove(entity);
        return Task.CompletedTask;
    }

    public Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default) =>
        _dbSet.AnyAsync(e => e.Id == id && !e.IsDeleted, cancellationToken);
}
