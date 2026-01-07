using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Utilisateur
{
    public short Id { get; set; }

    public string? Login { get; set; }

    public string? Mdp { get; set; }

    public string? Email { get; set; }

    public string? Codepin { get; set; }

    public DateTime? Derniereco { get; set; }

    public string? Niveauacces { get; set; }

    public virtual Personne IdNavigation { get; set; } = null!;
}
