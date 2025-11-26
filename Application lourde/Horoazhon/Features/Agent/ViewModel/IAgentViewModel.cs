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
    interface IAgentViewModel
    {

        string NomSearch { get; set; }
        List<Agent> Medecins { get; set; }
        Agent MedecinSelected { get; set; }

        List<RendezVous> RDVs { get; set; }
        RendezVous RDVSelected { get; set; }
        ObservableCollection<Visite> Consultations { get; }
        Visite ConsultationSelected { get; set; }
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
