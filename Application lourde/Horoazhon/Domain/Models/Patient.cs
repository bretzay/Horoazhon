using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Client
{
    public short Idpers { get; set; }

    public virtual Personne IdpersNavigation { get; set; } = null!;

    public virtual ICollection<Rendezvou> Rendezvous { get; set; } = new List<Rendezvou>();
}
