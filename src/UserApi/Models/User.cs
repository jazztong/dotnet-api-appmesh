using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace UserApi.Models
{
    public class User
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        public string Name { get; set; }

        public string Email { get; set; }
        public DateTime Created { get; set; } = DateTime.UtcNow;
    }
}