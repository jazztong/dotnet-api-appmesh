using System;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System.IO;
namespace ProductApi.Models
{
    public class ProductContext : DbContext
    {
        public ProductContext(DbContextOptions<ProductContext> options)
            : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            seedData(modelBuilder);
        }

        private void seedData(ModelBuilder modelBuilder)
        {
            var products = JsonConvert.DeserializeObject<Product[]>(File.ReadAllText(@"seed.json"));
            modelBuilder.Entity<Product>().HasData(products);
        }

        public DbSet<Product> Products { get; set; }
    }
}