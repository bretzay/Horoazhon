using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Achat
{
    public short IdOffrir { get; set; }

    public short Id { get; set; }

    public short? IdConclure { get; set; }

    public short Prix { get; set; }

    public DateTime? Datedispo { get; set; }

    public virtual ICollection<Contrat> Contrats { get; set; } = new List<Contrat>();

    public virtual Contrat? IdConclureNavigation { get; set; }

    public virtual Bien IdOffrirNavigation { get; set; } = null!;
}
