using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Lieux
{
    public int Id { get; set; }

    public short Lib { get; set; }

    public virtual ICollection<Deplacer> Deplacers { get; set; } = new List<Deplacer>();
}
