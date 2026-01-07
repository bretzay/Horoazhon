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

        private List<Personne>? _Personnes;
        public List<Personne> Personnes
        {
            get => _Personnes ?? new();
            set
            {
                _Personnes = value;
                OnPropertyChanged();
            }
        }

        private Personne? _PersonneSelected;
        public Personne? PersonneSelected
        {
            get => _PersonneSelected;
            set
            {
                _PersonneSelected = value;
                OnPropertyChanged();
                // ReloadVisite(); // Neutralized - linked to deleted Agenda service
            }
        }

        // Neutralized - linked to deleted Agenda service
        //private List<RendezVous>? _rdvs;
        //public List<RendezVous> RDVs
        //{
        //    get => _rdvs ?? new();
        //    set
        //    {
        //        _rdvs = value;
        //        OnPropertyChanged();
        //    }
        //}

        //private RendezVous _RDVSelected;
        //public RendezVous RDVSelected
        //{
        //    get => _RDVSelected ;
        //    set
        //    {
        //        _RDVSelected = value;
        //        OnPropertyChanged();
        //    }
        //}

        // Neutralized - linked to deleted Agenda service
        //private ObservableCollection<Visite> _Visite = new();
        //public ObservableCollection<Visite> Visite
        //{
        //    get => _Visite;
        //    set { _Visite = value; OnPropertyChanged(); }
        //}

        //private Visite? _Visiteelected;
        //public Visite? Visiteelected
        //{
        //    get => _Visiteelected;
        //    set
        //    {
        //        _Visiteelected = value;
        //        OnPropertyChanged();
        //    }
        //}

        public bool IsEditable { get; set; }

        public ICommand CommandPersonnesave { get; set; }
        public ICommand CommandPersonneDelete { get; set; }
        public ICommand CommandPersonnesearch { get; set; }
        public ICommand CommandPersonneCancel { get; set; }
        public ICommand CommandPersonneNew { get; set; }
        public ICommand CommandPersonneEdit { get; set; }

        public event PropertyChangedEventHandler? PropertyChanged;

        private void OnPropertyChanged([CallerMemberName] string? n = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));

        // Neutralized - linked to deleted Agenda service
        //private void ReloadVisite()
        //{
        //    Visite.Clear();
        //    if (PersonneSelected is null) return;

        //    // Neutralized - linked to deleted Agenda service (RendezVous navigation)
        //    //var items = _horoazhonContext.Visite.Where(c => c.RendezVous.IdpersClientNavigation == PersonneSelected).ToList();
        //    // foreach (var c in items) Visite.Add(c);
        //}

        public ClientViewModel()
        {
            _horoazhonContext = new HoroazhonContext();

            // Load all Personnes from the database
            Personnes = _horoazhonContext.Personnes.ToList();

            CommandPersonneCancel = new RelayCommand(_ => ActionPersonneCancel(), _ => CanActionPersonneCancel());
            CommandPersonneNew = new RelayCommand(_ => ActionPersonneNew());
            CommandPersonneDelete = new RelayCommand(_ => ActionPersonneDelete(), _ => CanActionPersonneDelete());
            CommandPersonnesave = new RelayCommand(_ => ActionPersonnesave(), _ => CanActionPersonnesave());
            CommandPersonneEdit = new RelayCommand(_ => ActionPersonneEdit(), _ => CanActionPersonneEdit());
            CommandPersonnesearch = new RelayCommand(_ => ActionPersonnesearch());
        }

        private void ActionPersonnesave()
        {
            if (PersonneSelected == null) return;

            Personne? existing = _horoazhonContext.Personnes
                 .FirstOrDefault(x => x.Siret == PersonneSelected.Siret && x.Id == PersonneSelected.Id);

            if (existing == null)
            {
                // Add new person
                _horoazhonContext?.Personnes.Add(PersonneSelected);
            }
            else
            {
                // Update existing
                _horoazhonContext?.Personnes.Update(existing);
            }

            _horoazhonContext?.SaveChanges();
            IsEditable = false;
            Personnes = _horoazhonContext?.Personnes.ToList() ?? new();
        }

        private bool CanActionPersonneDelete() => PersonneSelected != null;
        private bool CanActionPersonnesave() => PersonneSelected != null;
        private bool CanActionPersonneCancel() => true;
        private bool CanActionPersonneEdit() => PersonneSelected != null && !IsEditable;

        private void ActionPersonneEdit()
        {
            if (PersonneSelected != null)
                IsEditable = true;
        }

        private void ActionPersonneCancel()
        {
            IsEditable = false;
            Personnes = _horoazhonContext.Personnes.ToList();
        }

        private void ActionPersonneNew()
        {
            PersonneSelected = new Personne
            {
                Siret = "", // Default or get from user context
                Nom = "",
                Prenom = "",
                Datenais = DateTime.Now,
                Derniereco = DateTime.Now
            };
            IsEditable = true;
            OnPropertyChanged(nameof(PersonneSelected));
            OnPropertyChanged(nameof(IsEditable));
        }

        private void ActionPersonneDelete()
        {
            if (PersonneSelected == null) return;

            _horoazhonContext.Personnes.Remove(PersonneSelected);
            _horoazhonContext.SaveChanges();

            Personnes = _horoazhonContext.Personnes.ToList() ?? new();
            PersonneSelected = null;
        }

        private void ActionPersonnesearch()
        {
            if (string.IsNullOrWhiteSpace(NomSearch))
                Personnes = _horoazhonContext.Personnes.ToList();
            else
                Personnes = _horoazhonContext.Personnes
                    .Where(p => p.Nom.Contains(NomSearch))
                    .ToList();
        }
    }
}
