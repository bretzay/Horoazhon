using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Contrat
{
    public short Id { get; set; }

    public short? IdConclure { get; set; }

    public short? IdSigner { get; set; }

    public short? IdOffrir { get; set; }

    public short? IdEtreDisponible { get; set; }

    public DateTime? Datecont { get; set; }

    public virtual Achat? Achat { get; set; }

    public virtual ICollection<Achat> Achats { get; set; } = new List<Achat>();

    public virtual ICollection<Cosigner> Cosigners { get; set; } = new List<Cosigner>();

    public virtual Location? Location { get; set; }

    public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
}
