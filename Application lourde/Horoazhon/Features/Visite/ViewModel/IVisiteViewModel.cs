using Horoazhon.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Consultations.ViewModel
{
    interface IVisiteViewModel
    {
        Visite ConsultationSelected { get; set; }
        string ConsultationDate { get; }
        string ConsultationMedecinNom { get; set; }
        string ConsultationClientNom { get; set; }
        string? ConsultationMotif { get; set; }
        List<Visite>? Consultations { get; set; }
        List<RendezVous>? Rdvs { get; set; }
        ICommand CommandConsultationSave { get; }
        ICommand CommandConsultationCancel { get; }
        ICommand CommandPrint { get; }
        ICommand CommandTeleconsultation { get; }
        void ReloadConsultationSelected(RendezVous elem);
    }
}
