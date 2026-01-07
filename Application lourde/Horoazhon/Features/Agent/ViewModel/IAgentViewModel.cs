using Horoazhon.Domain.Models;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Personnes.ViewModel
{
    interface IAgentViewModel
    {
        string NomSearch { get; set; }
        List<Personne> Personnes { get; set; }
        Personne PersonneSelected { get; set; }

        // Neutralized - linked to deleted Agenda service
        //List<RendezVous> RDVs { get; set; }
        //RendezVous RDVSelected { get; set; }
        //ObservableCollection<Visite> Visite { get; }
        //Visite Visiteelected { get; set; }
        bool IsEditable { get; set; }
        ICommand CommandAgentNew { get; set; }
        ICommand CommandAgentEdit { get; set; }
        ICommand CommandAgentSave { get; set; }
        ICommand CommandAgentDelete { get; set; }
        ICommand CommandAgentSearch { get; set; }
        ICommand CommandAgentCancel { get; set; }
    }
}
