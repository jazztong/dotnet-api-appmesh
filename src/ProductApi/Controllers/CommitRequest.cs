using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ProductApi.Controllers
{
    public class CommitRequest
    {
        [Required]
        public int? CommitQty { get; set; }
    }
}