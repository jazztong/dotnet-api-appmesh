using System;
namespace OrderApi.Service
{
    public class ProductDto
    {
        public long Id { get; set; }
        public string Title { get; set; }
        public Decimal Price { get; set; }
        public string Description { get; set; }
        public string Category { get; set; }
        public string Image { get; set; }
        public int StockQty { get; set; }
    }
}