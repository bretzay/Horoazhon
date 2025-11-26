using Horoazhon.Domain.Models;
using Horoazhon.Services.Agenda;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Rdvs.ViewModel
{
    public interface IRdvViewModel
    {
        SlotService RdvSlotService { get; set; }
        List<Client> RdvClients { get; }
        Client? RdvClientselected { get; set; }

        string RdvNomMedecin { get; }
        string RdvDate { get; }
        string RdvCommentaire { get; set; }
        RendezVous RdvSelected { get; set; }

        List<RendezVous> Rdvs { get; set; }
        bool IsEditable { get; set; }
        void Update();

        ICommand CommandRdvSave { get; }
        ICommand CommandRdvIndisponibiliteSave { get; }
        ICommand CommandRdvDelete { get; }
    }
}
