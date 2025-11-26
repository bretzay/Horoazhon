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

namespace Horoazhon.Features.Medecins.ViewModel
{
    internal class AgentViewModel :  INotifyPropertyChanged, IAgentViewModel
    {
        HoroazhonContext? _cabinetmartinContext;

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

        private List<Agent>? _medecins;
        public List<Agent> Medecins
        {
            get => _medecins ?? new();
            set
            {
                _medecins = value;
                OnPropertyChanged();
            }
        }

        private Agent? _medecinSelected;
        public Agent MedecinSelected
        {
            get => _medecinSelected ?? new();
            set
            {
                _medecinSelected = value;
                OnPropertyChanged();
                ReloadConsultations();
            }
        }


        private List<RendezVous>? _rDVs;
        public List<RendezVous> RDVs
        {
            get => _rDVs ?? new();
            set
            {
                _rDVs = value;
                OnPropertyChanged();
            }
        }

        private RendezVous? _rDVSelected;
        public RendezVous RDVSelected
        {
            get => _rDVSelected ?? new();
            set
            {
                _rDVSelected = value;
                OnPropertyChanged();
            }
        }
        public ObservableCollection<Visite> Consultations { get; } = new();
        private List<Visite>? _consultations;

        private Visite? _consultationSelected;
        public Visite ConsultationSelected
        {
            get => _consultationSelected ?? new();
            set
            {

                _consultationSelected = value ?? new();
                OnPropertyChanged();
            }
        }
        private void ReloadConsultations()
        {
            Consultations.Clear();
            if (MedecinSelected is null) return;

            var items = _cabinetmartinContext?.Consultations
                .Where(c => c.RendezVous != null
                         && c.RendezVous.IdpersmedecinNavigation != null
                         && c.RendezVous.IdpersmedecinNavigation.Idpers == MedecinSelected.Idpers) // compare par Id
                .OrderBy(c => c.Datedebutrdv)
                .ToList() ?? new();

            foreach (var c in items) Consultations.Add(c);
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
        public ICommand CommandMedecinNew { get; set; }
        public void ActionMedecinNew()
        {
            MedecinSelected = new Agent()
            {
                IdpersNavigation = new Personne() { Rolepers = "Agent" }


            };
            IsEditable = true;
        }
        public ICommand CommandMedecinEdit { get; set; }
        private void ActionMedecinEdit()

        {
            IsEditable = true;
        }

        private bool CanActionMedecinEdit()
        {
            return MedecinSelected != null && !IsEditable;
        }

        public ICommand CommandMedecinSave { get; set; }
        private void ActionMedecinSave()
        {

            Personne? _medecin = Medecins.Where(x => x.Idpers == MedecinSelected.Idpers).FirstOrDefault();
            if (_medecin == null)
            {
                //MedecinSelected.IdpersMedecinNavigation.Rolepers = ;
                Personne _personne = new Personne()
                {
                    Nompers = MedecinSelected.IdpersNavigation?.Nompers,
                    Prenompers = MedecinSelected.IdpersNavigation?.Prenompers,
                    Telpers = MedecinSelected.IdpersNavigation?.Telpers,
                    Rolepers = "Agent",
                    Emailpers = MedecinSelected?.IdpersNavigation?.Emailpers,
                };
                _cabinetmartinContext?.Personnes.Add(_personne);
                _cabinetmartinContext?.SaveChanges();
                Trace.TraceInformation($"{UserService.UserName} a ajouté {_personne.Idpers}");

            }
            else
            {
                _cabinetmartinContext?.Medecins.Update(_medecin);
                Trace.TraceInformation($"{UserService.UserName} a modifié {_medecin.Idpers}");
            }

            _cabinetmartinContext?.SaveChanges();
            IsEditable = false;
            Medecins = _cabinetmartinContext?.Medecins.ToList() ?? new();
        }

        private bool CanActionMedecinSave()
        {
            return MedecinSelected != null;
        }

        public ICommand CommandMedecinDelete { get; set; }
        private void ActionMedecinDelete()
        {
            _cabinetmartinContext?.Medecins.Remove(MedecinSelected);
            _cabinetmartinContext?.SaveChanges();
            Medecins = _cabinetmartinContext?.Medecins.ToList() ?? new();
            Trace.TraceInformation($"{UserService.UserName} a supprimé {MedecinSelected.Idpers}");


        }
        private bool CanActionMedecinDelete()
        {
            return MedecinSelected != null;
        }
        public ICommand CommandMedecinSearch { get; set; }
        public void ActionMedecinSearch()
        {
            if (NomSearch != null && Medecins != null)
            {
                Medecins = Medecins!.Where(x => x.IdpersNavigation!.Nompers!.Contains(NomSearch)).ToList();
                if (Medecins.Count == 0)
                {
                    Medecins = _cabinetmartinContext?.Medecins.ToList() ?? new();
                    NomSearch = "Pas de correspondance";
                }
            }
        }
        public ICommand CommandMedecinCancel { get; set; }


        private void ActionMedecinCancel()
        {
            MedecinSelected = Medecins[Medecins.IndexOf(MedecinSelected)];
        }
        private bool CanActionMedecinCancel()
        {
            return MedecinSelected != null && Medecins.Contains(MedecinSelected);
        }


        public AgentViewModel()
        {
            _cabinetmartinContext = new HoroazhonContext();
            List<Utilisateur> lc = _cabinetmartinContext.Connexions.ToList();
            Medecins = _cabinetmartinContext.Medecins.ToList();
            CommandMedecinCancel = new RelayCommand(_ => ActionMedecinCancel(), _ => CanActionMedecinCancel());
            CommandMedecinNew = new RelayCommand(_ => ActionMedecinNew());
            CommandMedecinDelete = new RelayCommand(_ => ActionMedecinDelete(), _ => CanActionMedecinDelete());
            CommandMedecinSave = new RelayCommand(_ => ActionMedecinSave(), _ => CanActionMedecinSave());
            CommandMedecinEdit = new RelayCommand(_ => ActionMedecinEdit(), _ => CanActionMedecinEdit());
            CommandMedecinSearch = new RelayCommand(_ => ActionMedecinSearch());
        }
    }
}

