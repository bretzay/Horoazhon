using Horoazhon.Domain.Models;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Medecins.ViewModel
{
    interface IMedecinViewModel
    {

        string NomSearch { get; set; }
        List<Medecin> Medecins { get; set; }
        Medecin MedecinSelected { get; set; }

        List<Rendezvou> RDVs { get; set; }
        Rendezvou RDVSelected { get; set; }
        ObservableCollection<Consultation> Consultations { get; }
        Consultation ConsultationSelected { get; set; }
        bool IsEditable { get; set; }
        ICommand CommandMedecinNew { get; set; }
        ICommand CommandMedecinEdit { get; set; }



        ICommand CommandMedecinSave { get; set; }
        ICommand CommandMedecinDelete { get; set; }
        ICommand CommandMedecinSearch { get; set; }
        ICommand CommandMedecinCancel
        {
            get; set;
        }
    }
}
