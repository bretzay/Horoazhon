using Horoazhon.Domain.Models;
using Microsoft.UI.Xaml.Media;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Horoazhon.Services.Agenda
{
    public class SlotService
    {
        public Rendezvou? RDV { get; set; }

        public DateTimeOffset StartTime { get; set; }
        public DateTimeOffset EndTime { get; set; }
        public string? Statut { get; set; }
        public bool IsEditable { get; set; } = true;
        public SolidColorBrush? BackgroundColor { get; set; }
        public Medecin? OneMedecin { get; set; }
    }
}
