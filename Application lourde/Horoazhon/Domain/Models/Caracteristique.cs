using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Caracteristique
{
    public string Id { get; set; } = null!;

    public string Lib { get; set; } = null!;

    public virtual ICollection<Contenir> Contenirs { get; set; } = new List<Contenir>();
}
