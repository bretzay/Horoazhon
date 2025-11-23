using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Rendezvou
{
    public short Idpersmedecin { get; set; }

    public DateTimeOffset Datedebutrdv { get; set; }

    public DateTimeOffset Datefinrdv { get; set; }

    public string? Commentairerdv { get; set; }

    public short? IdpersClient { get; set; }

    public bool? Disponibilite { get; set; }

    public virtual ICollection<Consultation> Consultations { get; set; } = new List<Consultation>();

    public virtual Medecin IdpersmedecinNavigation { get; set; } = null!;

    public virtual Client? IdpersClientNavigation { get; set; }
}
