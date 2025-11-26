using System;
using System.Collections.Generic;

namespace Horoazhon.Domain.Models;

public partial class Photo
{
    public short IdApparaitre { get; set; }

    public string Id { get; set; } = null!;

    public byte[]? Fichier { get; set; }

    public virtual Bien IdApparaitreNavigation { get; set; } = null!;
}
