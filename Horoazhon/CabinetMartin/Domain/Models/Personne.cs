using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Personne
{
    public short Idpers { get; set; }

    public string? Nompers { get; set; }

    public string? Prenompers { get; set; }

    public string? Rolepers { get; set; }

    public string? Emailpers { get; set; }

    public string? Telpers { get; set; }

    public DateTime? Datecreation { get; set; }

    public virtual Connexion? Connexion { get; set; }

    public virtual Medecin? Medecin { get; set; }

    public virtual Client? Client { get; set; }
}
