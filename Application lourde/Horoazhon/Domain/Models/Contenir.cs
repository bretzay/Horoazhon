using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Contenir
{
    public string Id { get; set; } = null!;

    public short Id1 { get; set; }

    public string? Unite { get; set; }

    public string? Valeur { get; set; }

    public virtual Bien Id1Navigation { get; set; } = null!;

    public virtual Caracteristique IdNavigation { get; set; } = null!;
}
