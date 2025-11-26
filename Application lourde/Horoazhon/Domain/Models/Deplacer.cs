using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Deplacer
{
    public short Id { get; set; }

    public int Id1 { get; set; }

    public byte? Minutes { get; set; }

    public string? Typelocomotion { get; set; }

    public virtual Lieux Id1Navigation { get; set; } = null!;

    public virtual Bien IdNavigation { get; set; } = null!;
}
