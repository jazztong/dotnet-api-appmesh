using System;
using System.Threading.Tasks;

namespace OrderApi.Service
{
    public interface IProductService
    {
        Task<ProductDto> GetByIdAsync(string productId, bool fromCache = true);
        Task<CommitOrderDto> CommitOrderAsync(string productId, int qty);
    }
}