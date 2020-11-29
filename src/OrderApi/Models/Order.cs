using System.ComponentModel.DataAnnotations;
using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Collections.Generic;

namespace OrderApi.Models
{
    public class Order
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [Required]
        public long UserId { get; set; }
        public DateTime Created { get; set; }
        public ICollection<OrderItem> OrderItems { get; set; }
        public Decimal TotalPrice { get; set; }
    }
}