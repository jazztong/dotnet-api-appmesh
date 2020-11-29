using System;
using Microsoft.EntityFrameworkCore;
namespace UserApi.Models
{
    public class UserContext : DbContext
    {
        public UserContext(DbContextOptions<UserContext> options)
            : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>()
                .HasIndex(b => b.Email)
                .IsUnique();
            seedData(modelBuilder);
        }

        private void seedData(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>().HasData(
                new User { Id = 1, Name = "Jazz Tong", Email = "jazz@live.com" }
                );
        }

        public DbSet<User> Users { get; set; }
    }
}