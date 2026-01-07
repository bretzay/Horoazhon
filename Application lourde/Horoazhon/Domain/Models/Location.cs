using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Location
{
    public short IdEtreDisponible { get; set; }

    public short Id { get; set; }

    public short? IdSigner { get; set; }

    public int Caution { get; set; }

    public string? Datedispo { get; set; }

    public short Mensualite { get; set; }

    public virtual ICollection<Contrat> Contrats { get; set; } = new List<Contrat>();

    public virtual Bien IdEtreDisponibleNavigation { get; set; } = null!;

    public virtual Contrat? IdSignerNavigation { get; set; }
}
