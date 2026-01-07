using Azure.Messaging;
using Horoazhon.Domain.Models;
using Horoazhon.Services.Command;
using Horoazhon.Services.User;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using Windows.System;
using Windows.UI.Popups;

namespace Horoazhon.Features.Personnes.ViewModel
{
    internal class AgentViewModel : INotifyPropertyChanged, IAgentViewModel
    {
        HoroazhonContext? _horoazhonContext;

        public event PropertyChangedEventHandler? PropertyChanged;
        private void OnPropertyChanged([CallerMemberName] string? n = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));

        private string? _nomSearch;
        public string NomSearch
        {
            get => _nomSearch ?? "";
            set
            {
                _nomSearch = value;
                OnPropertyChanged();
            }
        }

        private List<Personne>? _personnes;
        public List<Personne> Personnes
        {
            get => _personnes ?? new();
            set
            {
                _personnes = value;
                OnPropertyChanged();
            }
        }

        private Personne? _personneSelected;
        public Personne PersonneSelected
        {
            get => _personneSelected ?? new();
            set
            {
                _personneSelected = value;
                OnPropertyChanged();
                // ReloadVisite(); // Neutralized - linked to deleted Agenda service
            }
        }

        // Neutralized - linked to deleted Agenda service
        //private List<RendezVous>? _rDVs;
        //public List<RendezVous> RDVs
        //{
        //    get => _rDVs ?? new();
        //    set
        //    {
        //        _rDVs = value;
        //        OnPropertyChanged();
        //    }
        //}

        //private RendezVous? _rDVSelected;
        //public RendezVous RDVSelected
        //{
        //    get => _rDVSelected ?? new();
        //    set
        //    {
        //        _rDVSelected = value;
        //        OnPropertyChanged();
        //    }
        //}

        // Neutralized - linked to deleted Agenda service
        //public ObservableCollection<Visite> Visite { get; } = new();
        //private List<Visite>? _Visite;

        //private Visite? _Visiteelected;
        //public Visite Visiteelected
        //{
        //    get => _Visiteelected ?? new();
        //    set
        //    {
        //        _Visiteelected = value ?? new();
        //        OnPropertyChanged();
        //    }
        //}

        //private void ReloadVisite()
        //{
        //    Visite.Clear();
        //    if (PersonneSelected is null) return;

        //    // Neutralized - linked to deleted Agenda service (RendezVous navigation)
        //    //var items = _horoazhonContext?.Visite
        //    //    .Where(c => c.RendezVous != null
        //    //             && c.RendezVous.IdpersmedecinNavigation != null
        //    //             && c.RendezVous.IdpersmedecinNavigation.Idpers == PersonneSelected.Idpers) // compare par Id
        //    //    .OrderBy(c => c.Datedebutrdv)
        //    //    .ToList() ?? new();

        //    //foreach (var c in items) Visite.Add(c);
        //}

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

        public ICommand CommandAgentNew { get; set; }
        public void ActionAgentNew()
        {
            PersonneSelected = new Personne()
            {
                Nom = "",
                Prenom = "",
                Siret = "",
                Datenais = DateTime.Now,
                Derniereco = DateTime.Now
            };
            IsEditable = true;
        }

        public ICommand CommandAgentEdit { get; set; }
        private void ActionAgentEdit()
        {
            IsEditable = true;
        }

        private bool CanActionAgentEdit()
        {
            return PersonneSelected != null && !IsEditable;
        }

        public ICommand CommandAgentSave { get; set; }
        private void ActionAgentSave()
        {
            if (PersonneSelected == null) return;

            Personne? _agent = Personnes.Where(x => x.Siret == PersonneSelected.Siret && x.Id == PersonneSelected.Id).FirstOrDefault();
            if (_agent == null)
            {
                // Add new person
                _horoazhonContext?.Personnes.Add(PersonneSelected);
                _horoazhonContext?.SaveChanges();
                Trace.TraceInformation($"{UserService.UserName} a ajouté {PersonneSelected.Id}");
            }
            else
            {
                _horoazhonContext?.Personnes.Update(_agent);
                Trace.TraceInformation($"{UserService.UserName} a modifié {_agent.Id}");
            }

            _horoazhonContext?.SaveChanges();
            IsEditable = false;
            Personnes = _horoazhonContext?.Personnes.ToList() ?? new();
        }

        private bool CanActionAgentSave()
        {
            return PersonneSelected != null;
        }

        public ICommand CommandAgentDelete { get; set; }
        private void ActionAgentDelete()
        {
            _horoazhonContext?.Personnes.Remove(PersonneSelected);
            _horoazhonContext?.SaveChanges();
            Personnes = _horoazhonContext?.Personnes.ToList() ?? new();
            Trace.TraceInformation($"{UserService.UserName} a supprimé {PersonneSelected.Id}");
        }

        private bool CanActionAgentDelete()
        {
            return PersonneSelected != null;
        }

        public ICommand CommandAgentSearch { get; set; }
        public void ActionAgentSearch()
        {
            if (NomSearch != null && Personnes != null)
            {
                Personnes = Personnes!.Where(x => x.Nom!.Contains(NomSearch)).ToList();
                if (Personnes.Count == 0)
                {
                    Personnes = _horoazhonContext?.Personnes.ToList() ?? new();
                    NomSearch = "Pas de correspondance";
                }
            }
        }

        public ICommand CommandAgentCancel { get; set; }

        private void ActionAgentCancel()
        {
            PersonneSelected = Personnes[Personnes.IndexOf(PersonneSelected)];
        }

        private bool CanActionAgentCancel()
        {
            return PersonneSelected != null && Personnes.Contains(PersonneSelected);
        }

        public AgentViewModel()
        {
            _horoazhonContext = new HoroazhonContext();
            List<Utilisateur> lc = _horoazhonContext.Utilisateurs.ToList();
            Personnes = _horoazhonContext.Personnes.ToList();
            CommandAgentCancel = new RelayCommand(_ => ActionAgentCancel(), _ => CanActionAgentCancel());
            CommandAgentNew = new RelayCommand(_ => ActionAgentNew());
            CommandAgentDelete = new RelayCommand(_ => ActionAgentDelete(), _ => CanActionAgentDelete());
            CommandAgentSave = new RelayCommand(_ => ActionAgentSave(), _ => CanActionAgentSave());
            CommandAgentEdit = new RelayCommand(_ => ActionAgentEdit(), _ => CanActionAgentEdit());
            CommandAgentSearch = new RelayCommand(_ => ActionAgentSearch());
        }
    }
}
