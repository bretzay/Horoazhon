using Horoazhon.Domain.Models;
using Horoazhon.Services.Agenda;
using Horoazhon.Services.Command;
using Horoazhon.Services.User;
using Microsoft.EntityFrameworkCore;
using Microsoft.UI.Xaml;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.DirectoryServices.ActiveDirectory;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;
using Windows.System;

namespace Horoazhon.Features.Rdvs.ViewModel
{
    internal class RdvsViewModel : IRdvViewModel, INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler? PropertyChanged;
        private void OnPropertyChanged([CallerMemberName] string? n = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));
        HoroazhonContext cabinetmartinContext;
        private List<Client> _rdvClients;
        public List<Client> RdvClients
        {
            get => _rdvClients;
            set
            {
                _rdvClients = value;
                OnPropertyChanged();
            }
        }

        private List<RendezVous> _rdvs;
        public List<RendezVous> Rdvs
        {
            get => _rdvs;
            set
            {
                _rdvs = value;
                OnPropertyChanged();
            }
        }
        private RendezVous? _rdvSelected;
        public RendezVous RdvSelected
        {
            get
            {
                return _rdvSelected ?? new();
            }
            set
            {
                _rdvSelected = value;
                OnPropertyChanged();
            }
        }
        private Client? _rdvClientselected;
        public Client? RdvClientselected
        {
            get => _rdvClientselected;
            set
            {
                _rdvClientselected = value ?? new();

                OnPropertyChanged();
            }
        }
        private SlotService _rdvSlotService;
        public SlotService RdvSlotService
        {
            get => _rdvSlotService;
            set
            {
                _rdvSlotService = value;
                Update();
                OnPropertyChanged();
            }
        }
        private string _rdvNomMedecin;
        public string RdvNomMedecin
        {
            get => _rdvNomMedecin;

        }
        private string _rdvDate;
        public string RdvDate
        {
            get => _rdvDate;
        }
        private string _rdvCommentaire;
        public string RdvCommentaire
        {
            get => _rdvCommentaire;
            set
            {
                _rdvCommentaire = value;
                OnPropertyChanged();
            }
        }
        private bool _isEditable = false;
        public bool IsEditable
        {
            get => _isEditable;
            set
            {
                _isEditable = value;
                OnPropertyChanged();
            }
        }

        private bool _disponibilite = true;
        public bool Disponibilite
        {
            get => _disponibilite;
            set
            {
                _disponibilite = value;
                OnPropertyChanged();
            }
        }
        private Client _rdvNewClient;
        public Client? RdvNewClient
        {
            get => _rdvNewClient;
            set
            {
                _rdvNewClient = value ?? new();
                OnPropertyChanged();
            }
        }
        public ICommand CommandRdvIndisponibiliteSave { get; }
        public void ActionRdvIndisponibiliteSave()
        {
            RdvSelected.IdpersClientNavigation = RdvClientselected;
            RdvSelected.Commentairerdv = RdvCommentaire;
            RdvSelected.Disponibilite = Disponibilite;
            var local = cabinetmartinContext.Rendezvous.AsNoTracking().Any(x => RdvSelected.Datedebutrdv == x.Datedebutrdv && x.Idpersmedecin == RdvSelected.Idpersmedecin && x.Datefinrdv == RdvSelected.Datefinrdv);
            if (local)
                cabinetmartinContext.Attach(RdvSelected);
            cabinetmartinContext.Entry(RdvSelected).State = local ? EntityState.Modified : EntityState.Added;
            Trace.TraceInformation($"{UserService.UserName} a ajouté le rdv ou modifié le rendez-vous du {RdvSelected.Datedebutrdv} avec Dr. {RdvNomMedecin}");
            Rdvs = cabinetmartinContext.Rendezvous.ToList();
            cabinetmartinContext.SaveChanges();
            // Pour recharger la liste ss multiplier les suivis :
            Rdvs = cabinetmartinContext.Rendezvous.AsNoTracking().ToList();
        }
        public ICommand CommandRdvSave { get; set; }

        public void ActionRdvSave()
        {

            RdvSelected.IdpersClientNavigation = RdvClientselected;

            RdvSelected.Commentairerdv = RdvCommentaire;
            RdvSelected.Disponibilite = true;
            var local = cabinetmartinContext.Rendezvous.AsNoTracking().Any(x => RdvSelected.Datedebutrdv == x.Datedebutrdv && x.Idpersmedecin == RdvSelected.Idpersmedecin && x.Datefinrdv == RdvSelected.Datefinrdv);
            if (local)
                cabinetmartinContext.Attach(RdvSelected);
            cabinetmartinContext.Entry(RdvSelected).State = local ? EntityState.Modified : EntityState.Added;
            Rdvs = cabinetmartinContext.Rendezvous.ToList();
            cabinetmartinContext.SaveChanges();
            Rdvs = cabinetmartinContext.Rendezvous.AsNoTracking().ToList();
        }
        public bool CanRdvSave()
        {
            return RdvSelected != null && RdvClientselected != null /*&& RdvSelected.Datedebutrdv<=DateTime.Now*/;

        }
        public ICommand CommandRdvDelete { get; }


        public void ActionRdvDelete()
        {
            var local = cabinetmartinContext!.Rendezvous.AsNoTracking().FirstOrDefault(x => x.Datefinrdv == RdvSelected.Datefinrdv && x.Datedebutrdv == RdvSelected.Datedebutrdv && x.Idpersmedecin == RdvSelected.Idpersmedecin);
            if (local != null)
            {
                cabinetmartinContext!.Entry(RdvSelected).State = EntityState.Deleted;
                Trace.TraceInformation($"{UserService.UserName} a supprimé le rendez-vous du {RdvSelected.Datedebutrdv} avec Dr. {RdvNomMedecin}");
                cabinetmartinContext.SaveChanges();
                Rdvs = cabinetmartinContext.Rendezvous.ToList();
            }
        }
/*        public bool CanRdvDelete()
        {
            Domain.Models.Consultation? consultation = cabinetmartinContext.Consultations.Where(x => x.RendezVous!.Equals(RdvSelected)).FirstOrDefault();
            return consultation == null && cabinetmartinContext!.Rendezvous.AsNoTracking().FirstOrDefault(x => x.Datefinrdv == RdvSelected.Datefinrdv && x.Datedebutrdv == RdvSelected.Datedebutrdv && x.Idpersmedecin == RdvSelected.Idpersmedecin) != null;
        }*/

        public RdvsViewModel()
        {
            cabinetmartinContext = new HoroazhonContext();
            Rdvs = cabinetmartinContext.Rendezvous.ToList();
            RdvClients = cabinetmartinContext.Clients.ToList();
            // Update();
            CommandRdvSave = new RelayCommand(_ => ActionRdvSave()/*, _ => CanRdvSave()*/);
          //  CommandRdvDelete = new RelayCommand(_ => ActionRdvDelete(), _ => CanRdvDelete());
            CommandRdvIndisponibiliteSave = new RelayCommand(_ => ActionRdvIndisponibiliteSave());

            if (UserService.UserRole.Equals("secretaire")) IsEditable = false; else IsEditable = true;
        } 
        public void Update()
        {
            if (RdvSlotService != null)
            {
                if (RdvSlotService.RDV != null)
                {
                    RdvSelected = RdvSlotService.RDV;
                    RdvSelected.Datedebutrdv = RdvSlotService.RDV.Datedebutrdv.ToUniversalTime();
                    RdvSelected.Datefinrdv = RdvSlotService.RDV.Datefinrdv.ToUniversalTime();

                    var idMed = RdvSlotService.RDV.Idpersmedecin;
                    var deb = RdvSelected.Datedebutrdv;
                    var fin = RdvSelected.Datefinrdv;
                    if (RdvSlotService.RDV.IdpersmedecinNavigation == null)
                    {
                        Agent? medecin = cabinetmartinContext.Medecins.Where(x => x.Idpers == idMed).FirstOrDefault();
                        RdvSelected.IdpersmedecinNavigation = medecin!;
                    }

                    var local = cabinetmartinContext.Rendezvous.FirstOrDefault(r =>
                        r.Idpersmedecin == idMed && r.Datedebutrdv == deb && r.Datefinrdv == fin);

                    if (local != null)
                    {
                        RdvSelected = local; // unifie la référence
                        RdvClientselected = RdvSelected.IdpersClientNavigation;
                        RdvClientselected!.Idpers = RdvClientselected.IdpersNavigation.Idpers;
                        RdvCommentaire = RdvSelected!.Commentairerdv ?? "";
                    }
                }
                else
                {
                    RdvSelected = new RendezVous();
                    RdvSelected.Datedebutrdv = (DateTimeOffset)RdvSlotService!.StartTime.ToUniversalTime();
                    RdvSelected.Datefinrdv = (DateTimeOffset)RdvSlotService!.EndTime.ToUniversalTime();
                    RdvSelected.IdpersmedecinNavigation = RdvSlotService!.OneMedecin!;
                    RdvSelected.Idpersmedecin = RdvSlotService!.OneMedecin!.Idpers;
                    RdvSelected.IdpersClientNavigation = RdvClientselected;
                    RdvSlotService.RDV = RdvSelected;
                }
                _rdvNomMedecin = $" Dr. {RdvSelected.IdpersmedecinNavigation.IdpersNavigation.Nompers}";
                _rdvDate = $"{RdvSelected.Datedebutrdv.ToString("g")} - {RdvSelected.Datefinrdv.ToString("g")}";
            }

        }
    }
}
