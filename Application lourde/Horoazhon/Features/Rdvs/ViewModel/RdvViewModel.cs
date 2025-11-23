/*using Horoazhon.Domain.Models;
using Horoazhon.Services.Agenda;
using Horoazhon.Services.Command;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Rdvs.ViewModel
{
    
        public class RdvViewModel : INotifyPropertyChanged, IRdvViewModel
        {
            private readonly CabinetContext _cabinetContext = new();

            public event PropertyChangedEventHandler? PropertyChanged;
            private void OnPropertyChanged([CallerMemberName] string? prop = null)
                => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(prop));

          //proprietes

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

            public List<Client> RdvClients { get; private set; }

            private Client? _rdvClientselected;
            public Client? RdvClientselected
            {
                get => _rdvClientselected;
                set
                {
                    _rdvClientselected = value;
                    OnPropertyChanged();
                }
            }

            private string _rdvNomMedecin = string.Empty;
            public string RdvNomMedecin
            {
                get => _rdvNomMedecin;
                set { _rdvNomMedecin = value; OnPropertyChanged(); }
            }

            private string _rdvDate = string.Empty;
            public string RdvDate
            {
                get => _rdvDate;
                set { _rdvDate = value; OnPropertyChanged(); }
            }

            private string _rdvCommentaire = string.Empty;
            public string RdvCommentaire
            {
                get => _rdvCommentaire;
                set { _rdvCommentaire = value; OnPropertyChanged(); }
            }

            private Rendezvou _rdvSelected = new();
            public Rendezvou RdvSelected
            {
                get => _rdvSelected;
                set { _rdvSelected = value; OnPropertyChanged(); }
            }

            private List<Rendezvou> _rdvs = new();
            public List<Rendezvou> Rdvs
            {
                get => _rdvs;
                set { _rdvs = value; OnPropertyChanged(); }
            }

            public bool IsEditable { get; set; }

           
            public ICommand CommandRdvSave { get; }
            public ICommand CommandRdvIndisponibiliteSave { get; }
            public ICommand CommandRdvDelete { get; }

            public RdvViewModel()
            {
                RdvClients = _cabinetContext.Clients.AsNoTracking().ToList();

            CommandRdvSave = new RelayCommand(_ => ActionRdvSave(), _ => true);
            CommandRdvIndisponibiliteSave = new RelayCommand(_ => ActionRdvIndisponibiliteSave(), _ => true);
            CommandRdvDelete = new RelayCommand(_ => ActionRdvDelete(), _ => RdvSelected != null);

        }


        public void ActionRdvSave()
            {
                RdvSelected.IdpersClientNavigation = RdvClientselected;
                RdvSelected.Commentairerdv = RdvCommentaire;
                RdvSelected.Disponibilite = true;

                bool local = _cabinetContext.Rendezvous
                    .AsNoTracking()
                    .Any(x =>
                        x.Datedebutrdv == RdvSelected.Datedebutrdv &&
                        x.Idpersmedecin == RdvSelected.Idpersmedecin &&
                        x.Datefinrdv == RdvSelected.Datefinrdv);

                if (local)
                    _cabinetContext.Attach(RdvSelected);

                _cabinetContext.Entry(RdvSelected).State = local ? EntityState.Modified : EntityState.Added;
                _cabinetContext.SaveChanges();

                Rdvs = _cabinetContext.Rendezvous.AsNoTracking().ToList();
            }
        //methode crud
            public void ActionRdvIndisponibiliteSave()
            {
                RdvSelected.IdpersClientNavigation = RdvClientselected;
                RdvSelected.Commentairerdv = RdvCommentaire;
                RdvSelected.Disponibilite = false;

                bool local = _cabinetContext.Rendezvous
                    .AsNoTracking()
                    .Any(x =>
                        x.Datedebutrdv == RdvSelected.Datedebutrdv &&
                        x.Idpersmedecin == RdvSelected.Idpersmedecin &&
                        x.Datefinrdv == RdvSelected.Datefinrdv);

                if (local)
                    _cabinetContext.Attach(RdvSelected);

                _cabinetContext.Entry(RdvSelected).State = local ? EntityState.Modified : EntityState.Added;
                _cabinetContext.SaveChanges();

                Rdvs = _cabinetContext.Rendezvous.AsNoTracking().ToList();
            }

            public void ActionRdvDelete()
            {
                var local = _cabinetContext.Rendezvous
                    .AsNoTracking()
                    .FirstOrDefault(x =>
                        x.Datefinrdv == RdvSelected.Datefinrdv &&
                        x.Datedebutrdv == RdvSelected.Datedebutrdv &&
                        x.Idpersmedecin == RdvSelected.Idpersmedecin);

                if (local != null)
                {
                    _cabinetContext.Entry(RdvSelected).State = EntityState.Deleted;
                    _cabinetContext.SaveChanges();
                    Rdvs = _cabinetContext.Rendezvous.AsNoTracking().ToList();
                }
            }

         //methode update
            public void Update()
            {
                if (RdvSlotService == null) return;

                if (RdvSlotService.RDV != null)
                {
                    RdvSelected = RdvSlotService.RDV;
                    RdvSelected.Datedebutrdv = RdvSelected.Datedebutrdv.ToUniversalTime();
                    RdvSelected.Datefinrdv = RdvSelected.Datefinrdv.ToUniversalTime();

                    var idMed = RdvSelected.Idpersmedecin;
                    var deb = RdvSelected.Datedebutrdv;
                    var fin = RdvSelected.Datefinrdv;

                    if (RdvSelected.IdpersmedecinNavigation == null)
                    {
                        var medecin = _cabinetContext.Medecins.FirstOrDefault(x => x.Idpers == idMed);
                        RdvSelected.IdpersmedecinNavigation = medecin!;
                    }

                    var local = _cabinetContext.Rendezvous
                        .FirstOrDefault(r => r.Idpersmedecin == idMed && r.Datedebutrdv == deb && r.Datefinrdv == fin);

                    if (local != null)
                    {
                        RdvSelected = local;
                        RdvClientselected = RdvSelected.IdpersClientNavigation;
                        RdvCommentaire = RdvSelected.Commentairerdv ?? "";
                    }
                }
                else
                {
                    RdvSelected = new Rendezvou
                    {
                        Datedebutrdv = RdvSlotService.StartTime.ToUniversalTime(),
                        Datefinrdv = RdvSlotService.EndTime.ToUniversalTime(),
                        IdpersmedecinNavigation = RdvSlotService.OneMedecin!,
                        Idpersmedecin = RdvSlotService.OneMedecin!.Idpers,
                        IdpersClientNavigation = RdvClientselected
                    };
                    RdvSlotService.RDV = RdvSelected;
                }

                RdvNomMedecin = $"Dr. {RdvSelected.IdpersmedecinNavigation.IdpersNavigation.Nompers}";
                RdvDate = $"{RdvSelected.Datedebutrdv:g} - {RdvSelected.Datefinrdv:g}";
            }
        }
    }


*/

using Horoazhon.Domain.Models;
using Horoazhon.Services.Agenda;
using Horoazhon.Services.Command;
using Horoazhon.Services.User;
using Horoazhon.Domain.Models;
using Horoazhon.Features.Rdvs.ViewModel;
using Horoazhon.Services.Agenda;
using Horoazhon.Services.Command;
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
        /// <summary>
        /// 
        /// </summary>
        public event PropertyChangedEventHandler? PropertyChanged;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="n"></param>
        private void OnPropertyChanged([CallerMemberName] string? n = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));
        /// <summary>
        /// 
        /// </summary>
        CabinetContext cabinetmartinContext;

        /// <summary>
        /// 
        /// </summary>
        private List<Client> _rdvClients;
        /// <summary>
        /// 
        /// </summary>
        public List<Client> RdvClients
        {
            get => _rdvClients;
            set
            {
                _rdvClients = value;
                OnPropertyChanged();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        private List<Rendezvou> _rdvs;
        /// <summary>
        /// 
        /// </summary>
        public List<Rendezvou> Rdvs
        {
            get => _rdvs;
            set
            {
                _rdvs = value;
                OnPropertyChanged();
            }
        }
        /// <summary>
        /// 
        /// </summary>
        private Rendezvou? _rdvSelected;
        /// <summary>
        /// 
        /// </summary>
        public Rendezvou RdvSelected
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
        /// <summary>
        /// 
        /// </summary>
        private Client? _rdvClientselected;
        /// <summary>
        /// 
        /// </summary>
        public Client? RdvClientselected
        {
            get => _rdvClientselected;
            set
            {
                _rdvClientselected = value ?? new();

                OnPropertyChanged();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        private SlotService _rdvSlotService;
        /// <summary>
        /// 
        /// </summary>
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
        /// <summary>
        /// 
        /// </summary>
        private string _rdvNomMedecin;
        /// <summary>
        /// 
        /// </summary>
        public string RdvNomMedecin
        {
            get => _rdvNomMedecin;

        }
        /// <summary>
        /// 
        /// </summary>
        private string _rdvDate;
        /// <summary>
        /// 
        /// </summary>
        public string RdvDate
        {
            get => _rdvDate;
        }
        /// <summary>
        /// 
        /// </summary>
        private string _rdvCommentaire;
        /// <summary>
        /// 
        /// </summary>
        public string RdvCommentaire
        {
            get => _rdvCommentaire;
            set
            {
                _rdvCommentaire = value;
                OnPropertyChanged();
            }
        }
        /// <summary>
        /// 
        /// </summary>
        private bool _isEditable = false;
        /// <summary>
        /// 
        /// </summary>
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
        /// <summary>
        /// 
        /// </summary>
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
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public bool CanRdvSave()
        {
            return RdvSelected != null && RdvClientselected != null /*&& RdvSelected.Datedebutrdv<=DateTime.Now*/;

        }
        /// <summary>
        /// 
        /// </summary>
        public ICommand CommandRdvDelete { get; }



        /// <summary>
        /// 
        /// </summary>
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
        /// <summary>
        /// 
        /// </summary>
        /// <returns>Consultation is null</returns>
/*        public bool CanRdvDelete()
        {
            Domain.Models.Consultation? consultation = cabinetmartinContext.Consultations.Where(x => x.Rendezvou!.Equals(RdvSelected)).FirstOrDefault();
            return consultation == null && cabinetmartinContext!.Rendezvous.AsNoTracking().FirstOrDefault(x => x.Datefinrdv == RdvSelected.Datefinrdv && x.Datedebutrdv == RdvSelected.Datedebutrdv && x.Idpersmedecin == RdvSelected.Idpersmedecin) != null;
        }*/





        public RdvsViewModel()
        {
            cabinetmartinContext = new CabinetContext();
            Rdvs = cabinetmartinContext.Rendezvous.ToList();
            RdvClients = cabinetmartinContext.Clients.ToList();
            // Update();
            CommandRdvSave = new RelayCommand(_ => ActionRdvSave()/*, _ => CanRdvSave()*/);
          //  CommandRdvDelete = new RelayCommand(_ => ActionRdvDelete(), _ => CanRdvDelete());
            CommandRdvIndisponibiliteSave = new RelayCommand(_ => ActionRdvIndisponibiliteSave());

            if (UserService.UserRole.Equals("secretaire")) IsEditable = false; else IsEditable = true;
        }

        /// <summary>
        /// Mise à jour des propriétés en fonction du slotservice
        /// </summary>
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
                        Medecin? medecin = cabinetmartinContext.Medecins.Where(x => x.Idpers == idMed).FirstOrDefault();
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
                    RdvSelected = new Rendezvou();
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
