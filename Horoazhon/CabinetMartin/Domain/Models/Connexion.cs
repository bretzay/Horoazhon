using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Connexion
{
    public short Idpers { get; set; }

    public string? Logincon { get; set; }

    public string? Mdpcon { get; set; }

    public string? Codepincon { get; set; }

    public DateTime? Datedernierecon { get; set; }

    public virtual Personne IdpersNavigation { get; set; } = null!;
}
