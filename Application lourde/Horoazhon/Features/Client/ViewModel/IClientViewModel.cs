using Horoazhon.Domain.Models;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Clients.ViewModel
{
    interface IClientViewModel
    {
        string NomSearch { get; set; }
        List<Personne> Personnes { get; set; }
        Personne? PersonneSelected { get; set; }

        // Neutralized - linked to deleted Agenda service
        //List<RendezVous> RDVs { get; set; }
        //RendezVous RDVSelected { get; set; }
        //ObservableCollection<Visite> Visite { get; }
        //Visite? Visiteelected { get; set; }
        bool IsEditable { get; set; }
        ICommand CommandPersonneNew { get; set; }
        ICommand CommandPersonneEdit { get; set; }
        ICommand CommandPersonnesave { get; set; }
        ICommand CommandPersonneDelete { get; set; }
        ICommand CommandPersonnesearch { get; set; }
        ICommand CommandPersonneCancel { get; set; }
    }
}
