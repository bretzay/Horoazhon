using Horoazhon.Domain.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Consultations.ViewModel
{
    interface IConsultationViewModel
    {
        Consultation ConsultationSelected { get; set; }
        string ConsultationDate { get; }
        string ConsultationMedecinNom { get; set; }
        string ConsultationClientNom { get; set; }
        string? ConsultationMotif { get; set; }
        List<Consultation>? Consultations { get; set; }
        List<Rendezvou>? Rdvs { get; set; }
        ICommand CommandConsultationSave { get; }
        ICommand CommandConsultationCancel { get; }
        ICommand CommandPrint { get; }
        ICommand CommandTeleconsultation { get; }
        void ReloadConsultationSelected(Rendezvou elem);
    }
}
