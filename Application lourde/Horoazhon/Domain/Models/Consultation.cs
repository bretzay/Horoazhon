using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Consultation
{
    public short Idcons { get; set; }

    public string? Motifcons { get; set; }

    public string? Notecons { get; set; }

    public string? Ordonnancecons { get; set; }

    public string? Statutcons { get; set; }

    public decimal? Prixcons { get; set; }

    public string? Lienweb { get; set; }

    public short Idpersmedecin { get; set; }

    public DateTimeOffset Datedebutrdv { get; set; }

    public DateTimeOffset Datefinrdv { get; set; }

    public bool? Indisponibilite { get; set; }

    public virtual RendezVous RendezVous { get; set; } = null!;
}
