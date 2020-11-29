using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OrderApi.Models;
using OrderApi.Service;

namespace OrderApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrdersController : ControllerBase
    {
        private readonly OrderContext _context;
        private readonly IProductService _product;

        public OrdersController(OrderContext context, IProductService product)
        {
            _context = context;
            _product = product;
        }

        // GET: api/Orders
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Order>>> GetOrders()
        {
            return await _context.Orders.Include(n => n.OrderItems).ToListAsync();
        }

        // GET: api/Orders/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Order>> GetOrder(long id)
        {
            var order = await _context.Orders.FindAsync(id);

            if (order == null)
            {
                return NotFound();
            }

            return order;
        }

        // PUT: api/Orders/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPut("{id}")]
        public async Task<IActionResult> PutOrder(long id, Order order)
        {
            if (id != order.Id)
            {
                return BadRequest();
            }

            _context.Entry(order).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!OrderExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Orders
        // To protect from overposting attacks, enable the specific properties you want to bind to, for
        // more details, see https://go.microsoft.com/fwlink/?linkid=2123754.
        [HttpPost]
        public async Task<ActionResult<Order>> PostOrder(Order order)
        {
            if (!await ProductHasStockAsync(order))
            {
                return BadRequest(new { Message = "Not enough stock for product" });
            }
            _context.Orders.Add(order);
            await _context.SaveChangesAsync();
            var commitSuccess = await CommitStockAsync(order);
            if (!commitSuccess)
            {
                return BadRequest("Commit order fail");
            }
            return CreatedAtAction("GetOrder", new { id = order.Id }, order);
        }

        // DELETE: api/Orders/5
        [HttpDelete("{id}")]
        public async Task<ActionResult<Order>> DeleteOrder(long id)
        {
            var order = await _context.Orders.FindAsync(id);
            if (order == null)
            {
                return NotFound();
            }

            _context.Orders.Remove(order);
            await _context.SaveChangesAsync();

            return order;
        }

        private bool OrderExists(long id)
        {
            return _context.Orders.Any(e => e.Id == id);
        }

        private async Task<bool> CommitStockAsync(Order order)
        {
            foreach (var orderItem in order.OrderItems)
            {
                var response = await _product.CommitOrderAsync(orderItem.ProductId.ToString(), orderItem.Qty);
                if (response == null)
                {
                    return false;
                }
            }
            return true;
        }

        private async Task<bool> ProductHasStockAsync(Order order)
        {
            foreach (var orderItem in order.OrderItems)
            {
                var product = await _product.GetByIdAsync(orderItem.ProductId.ToString());
                if ((product.StockQty - orderItem.Qty) < 0)
                {
                    return false;
                }
            }
            return true;
        }
    }
}
