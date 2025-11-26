using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Agence
{
    public string Siret { get; set; } = null!;

    public string Nom { get; set; } = null!;

    public string Numerotva { get; set; } = null!;

    public string Rue { get; set; } = null!;

    public string Ville { get; set; } = null!;

    public string Codepostal { get; set; } = null!;

    public virtual ICollection<Personne> Personnes { get; set; } = new List<Personne>();
}
