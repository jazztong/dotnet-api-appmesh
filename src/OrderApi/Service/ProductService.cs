using System;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace OrderApi.Service
{
    public class ProductService : IProductService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _config;
        private readonly ILogger<ProductService> _logger;
        private readonly string _productUrl;

        public ProductService(HttpClient httpClient, IConfiguration config, ILogger<ProductService> logger)
        {
            _httpClient = httpClient;
            _config = config;
            _logger = logger;
            _productUrl = config.GetValue<string>("Url:Product");
            if (_productUrl == null)
            {
                throw new System.Exception("Product Service Url not configure");
            }
        }

        public async Task<CommitOrderDto> CommitOrderAsync(string productId, int qty)
        {
            try
            {
                HttpContent request = new StringContent(JsonConvert.SerializeObject(new
                {
                    commitQty = qty
                }), Encoding.UTF8, "application/json"); ;
                var response = await _httpClient.PutAsync($"{_productUrl}/api/products/{productId}/commit/", request);
                if (response.IsSuccessStatusCode)
                {
                    return new CommitOrderDto { Success = true };
                }
                _logger.LogWarning($"Product Id {productId} not found");
                return null;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError($"HttpRequestException:{ex.Message}");
                throw ex;
            }
        }

        public async Task<ProductDto> GetByIdAsync(string productId, bool fromCache = true)
        {
            try
            {
                _logger.LogInformation($"Connect {_productUrl}/api/products/{productId}/{fromCache}");
                var response = await _httpClient.GetAsync($"{_productUrl}/api/products/{productId}/{fromCache}");
                if (response.IsSuccessStatusCode)
                {
                    var json = await response.Content.ReadAsStringAsync();
                    return JsonConvert.DeserializeObject<ProductDto>(json);
                }
                _logger.LogWarning($"Product Id {productId} not found");
                return null;
            }
            catch (HttpRequestException ex)
            {
                _logger.LogError($"HttpRequestException:{ex.Message}");
                throw ex;
            }
        }
    }
}