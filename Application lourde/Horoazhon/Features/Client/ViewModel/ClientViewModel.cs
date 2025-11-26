using Horoazhon.Domain.Models;
using Horoazhon.Services.Command;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows.Input;

namespace Horoazhon.Features.Clients.ViewModel
{
    public class ClientViewModel : IClientViewModel, INotifyPropertyChanged
    {

        HoroazhonContext? _horoazhonContext = new HoroazhonContext();

        private string? _nomSearch;
        public string NomSearch
        {
            get => _nomSearch ?? " ";
            set
            {
                _nomSearch = value;
                OnPropertyChanged();
            }
        }


        private List<Client>? _Clients;
        public List<Client> Clients
        {
            get => _Clients ?? new();
            set
            {
                _Clients = value;
                OnPropertyChanged();
            }
        }

        private Client _Clientselected;
        public Client Clientselected
        {
            get => _Clientselected;
            set
            {
                _Clientselected = value;
                OnPropertyChanged();
                ReloadConsultations();



                if (_Clientselected != null)
                {
                    // Charger les rendez-vous du Client sélectionné
                    RDVs = _horoazhonContext.Rendezvous
                        .Where(r => r.IdpersClient == _Clientselected.Idpers)
                        .ToList();


                    Consultations = new ObservableCollection<Visite>(
                        _horoazhonContext.Consultations
                            .Where(c => c.RendezVous.IdpersClient == _Clientselected.Idpers)
                            .ToList());
                }
                else
                {
                    RDVs = new List<RendezVous>();
                    Consultations = new ObservableCollection<Visite>();
                }
            }
        }

        private List<RendezVous>? _rdvs;
        public List<RendezVous> RDVs
        {
            get => _rdvs ?? new();
            set
            {
                _rdvs = value;
                OnPropertyChanged();
            }
        }

        private RendezVous _RDVSelected;
        public RendezVous RDVSelected
        {
            get => _RDVSelected ;
            set
            {
                _RDVSelected = value;
                OnPropertyChanged();
            }
        }

        private ObservableCollection<Visite> _consultations = new();
        public ObservableCollection<Visite> Consultations
        {
            get => _consultations;
            set { _consultations = value; OnPropertyChanged(); }
        }



        private Visite? _consultationSelected;
        public Visite? ConsultationSelected
        {
            get => _consultationSelected;
            set
            {
                _consultationSelected = value;
                OnPropertyChanged();
            }
        }

        public bool IsEditable { get; set; }
      

        public ICommand CommandClientsave { get; set; }
        public ICommand CommandClientDelete { get; set; }
        public ICommand CommandClientsearch { get; set; }
        public ICommand CommandClientCancel { get; set; }
        public ICommand CommandClientNew { get; set; }
        public ICommand CommandClientEdit { get; set; }

        public event PropertyChangedEventHandler? PropertyChanged;

        private void OnPropertyChanged([CallerMemberName] string? n = null)
 => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));

        private void ReloadConsultations()
        {
            Consultations.Clear();
            if (Clientselected is null) return;

            var items = _horoazhonContext.Consultations.Where(c => c.RendezVous.IdpersClientNavigation == Clientselected).ToList();

             foreach (var c in items) Consultations.Add(c);
        }

        public ClientViewModel()
        {
            _horoazhonContext = new HoroazhonContext();

            Clients = _horoazhonContext.Clients.ToList();
            CommandClientCancel = new RelayCommand(_ => ActionClientCancel(), _ => CanActionClientCancel());
            CommandClientNew = new RelayCommand(_ => ActionClientNew());
            CommandClientDelete = new RelayCommand(_ => ActionClientDelete(), _ => CanActionClientDelete());
            CommandClientsave = new RelayCommand(_ => ActionClientsave(), _ => CanActionClientsave());
            CommandClientEdit = new RelayCommand(_ => ActionClientEdit(), _ => CanActionClientEdit());
            CommandClientsearch = new RelayCommand(_ => ActionClientsearch());
        }
        private void ActionClientsave()
        {
            Client? _Client = _horoazhonContext.Clients
                 .FirstOrDefault(x => x.Idpers == Clientselected.Idpers);

            if (_Client == null)
            {
                Personne _personne = new Personne()
                {

                    Nompers = Clientselected.IdpersNavigation?.Nompers,
                    Prenompers = Clientselected.IdpersNavigation?.Prenompers,
                    Telpers = Clientselected.IdpersNavigation?.Telpers,
                    Rolepers = "Client",
                    Emailpers = Clientselected?.IdpersNavigation?.Emailpers,
                    Datecreation = DateTime.Now,
                    Client = Clientselected

                };
                _horoazhonContext?.Personnes.Add(_personne);
                _horoazhonContext?.SaveChanges();
            }
            else
            {
                _horoazhonContext?.Clients.Update(_Client);

            }

            _horoazhonContext?.SaveChanges();
            IsEditable = false;
            Clients = _horoazhonContext?.Clients.ToList() ?? new();
        }
        
        private bool CanActionClientDelete() => true; 
        private bool CanActionClientsave() => true; 
        private bool CanActionClientCancel() => true;
        private bool CanActionClientEdit() => true;
        private void ActionClientEdit()
        {
            if (Clientselected != null)
                IsEditable = true;
        }
        private void ActionClientCancel() {
            IsEditable = false;
            Clients = _horoazhonContext.Clients.ToList();
        }

        private void ActionClientNew() {
            Clientselected = new Client
            {
                IdpersNavigation = new Personne()
            };
            IsEditable = true;
            OnPropertyChanged(nameof(Clientselected));
            OnPropertyChanged(nameof(IsEditable));
        }

        private void ActionClientDelete() {
            if (Clientselected == null) return;

            _horoazhonContext.Clients.Remove(Clientselected);
            _horoazhonContext.SaveChanges();

            Clients = _horoazhonContext.Clients.ToList() ?? new();
            Clientselected = null;
        }
        private void ActionClientsearch() {

            if (string.IsNullOrWhiteSpace(NomSearch))
                Clients = _horoazhonContext.Clients.ToList();
            else
                Clients = _horoazhonContext.Clients
                    .Where(p => p.IdpersNavigation.Nompers.Contains(NomSearch))
                    .ToList();
        }
    }
}
