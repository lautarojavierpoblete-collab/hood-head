
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new
        {
            estado = "correcto",
            proyecto = "HOOD HEAD",
            mensaje = "La API está funcionando"
        });
    }
}
