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
        List<Client> Clients { get; set; }
        Client Clientselected { get; set; }

        List<RendezVous> RDVs { get; set; }
        RendezVous RDVSelected { get; set; }
        ObservableCollection<Consultation> Consultations { get; }
        Consultation ConsultationSelected { get; set; }
        bool IsEditable { get; set; }
        ICommand CommandClientNew { get; set; }
        ICommand CommandClientEdit { get; set; }
        


        ICommand CommandClientsave { get; set; }
        ICommand CommandClientDelete { get; set; }
        ICommand CommandClientsearch { get; set; }
        ICommand CommandClientCancel
        {
            get; set;
        }
    }
}