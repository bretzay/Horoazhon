using Horoazhon.Domain.Models;
using Horoazhon.Services;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using Horoazhon.Services.Agenda;

namespace Horoazhon.Features.Agenda.ViewModel
{
    internal interface IAgendaViewModel
    {
        List<Agent> Medecins {  get; }
        Agent MedecinSelected { get; set; }
        string NomMedecin { get; }
        List<string> SlotLabelList { get;}
        string LundiLabel { get; set; }
        string MardiLabel { get; set; }
        string MercrediLabel { get; set; }
        string JeudiLabel { get; set; }
        string VendrediLabel { get; set; }
        List<SlotService> LundiList { get; set; }
        List<SlotService> MardiList { get; set; }
        List<SlotService> MercrediList { get; set; }
        List<SlotService> JeudiList { get; set; }
        List<SlotService> VendrediList { get; set; }
        SlotService SlotSelected { get; set; }
        bool IsEnabledConsultation(SlotService slot);       
    
    }
}
