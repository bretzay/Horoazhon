using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Bien
{
    public short Id { get; set; }

    public string Rue { get; set; } = null!;

    public string Ville { get; set; } = null!;

    public string Codepostal { get; set; } = null!;

    public short? Ecoscore { get; set; }

    public short? Superficie { get; set; }

    public string Description { get; set; } = null!;

    public string Type { get; set; } = null!;

    public virtual ICollection<Achat> Achats { get; set; } = new List<Achat>();

    public virtual ICollection<Contenir> Contenirs { get; set; } = new List<Contenir>();

    public virtual ICollection<Deplacer> Deplacers { get; set; } = new List<Deplacer>();

    public virtual ICollection<Location> Locations { get; set; } = new List<Location>();

    public virtual ICollection<Photo> Photos { get; set; } = new List<Photo>();

    public virtual ICollection<Personne> Id1s { get; set; } = new List<Personne>();
}
