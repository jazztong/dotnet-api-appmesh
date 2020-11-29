using Microsoft.EntityFrameworkCore;
namespace OrderApi.Models
{
    public class OrderContext : DbContext
    {
        public OrderContext(DbContextOptions<OrderContext> options)
        : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Order>()
                .HasMany(c => c.OrderItems)
                .WithOne(e => e.Order);
        }

        public DbSet<Order> Orders { get; set; }
    }
}