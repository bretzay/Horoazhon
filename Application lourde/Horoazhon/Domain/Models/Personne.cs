using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Personne
{
    public string Siret { get; set; } = null!;

    public short Id { get; set; }

    public string? Rue { get; set; }

    public string? Ville { get; set; }

    public string? CodePostal { get; set; }

    public string? Rib { get; set; }

    public string Nom { get; set; } = null!;

    public string Prenom { get; set; } = null!;

    public DateTime Datenais { get; set; }

    public DateTime Derniereco { get; set; }

    public virtual ICollection<Cosigner> Cosigners { get; set; } = new List<Cosigner>();

    public virtual Agence SiretNavigation { get; set; } = null!;

    public virtual Utilisateur? Utilisateur { get; set; }

    public virtual ICollection<Bien> Ids { get; set; } = new List<Bien>();
}
