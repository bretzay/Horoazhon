using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Medecin
{
    public short Idpers { get; set; }

    public string Specmedecin { get; set; } = null!;

    public string Numsiretmedecin { get; set; } = null!;

    public virtual Personne IdpersNavigation { get; set; } = null!;

    public virtual ICollection<Rendezvou> Rendezvous { get; set; } = new List<Rendezvou>();
}
