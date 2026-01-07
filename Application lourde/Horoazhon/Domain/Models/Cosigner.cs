using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Cosigner
{
    public short Id { get; set; }

    public short Id1 { get; set; }

    public string? Typesignataire { get; set; }

    public virtual Contrat Id1Navigation { get; set; } = null!;

    public virtual Personne IdNavigation { get; set; } = null!;
}
