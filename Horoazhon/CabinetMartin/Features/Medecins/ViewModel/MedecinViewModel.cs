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
    /* public class MedecinViewModel : INotifyPropertyChanged
     {
         private readonly CabinetContext _cabinetContext;

         public MedecinViewModel()
         {
             _cabinetContext = new CabinetContext();

             Medecins = _cabinetContext.Medecins.ToList();
             CommandMedecinCancel = new RelayCommand(_ => ActionMedecinCancel(), _ => true);
             CommandMedecinNew = new RelayCommand(_ => ActionMedecinNew());
             CommandMedecinDelete = new RelayCommand(_ => ActionMedecinDelete(), _ => CanActionMedecinDelete());
             CommandMedecinSave = new RelayCommand(_ => ActionMedecinSave(), _ => CanActionMedecinSave());
             CommandMedecinEdit = new RelayCommand(_ => ActionMedecinEdit(), _ => CanActionMedecinEdit());
             CommandMedecinSearch = new RelayCommand(_ => ActionMedecinSearch());
         }

         private string? _nomSearch;
         public string NomSearch
         {
             get => _nomSearch ?? string.Empty;
             set
             {
                 _nomSearch = value;
                 OnPropertyChanged();
             }
         }

         private List<Medecin>? _medecins;
         public List<Medecin> Medecins
         {
             get => _medecins ?? new();
             set
             {
                 _medecins = value;
                 OnPropertyChanged();
             }
         }

         private Medecin? _medecinSelected;
         public Medecin? MedecinSelected
         {
             get => _medecinSelected;
             set
             {
                 _medecinSelected = value;
                 OnPropertyChanged();
                 ReloadConsultations();

                 if (_medecinSelected != null)
                 {
                     // Charger les rdv
                     RDVs = _cabinetContext.Rendezvous
                         .Where(r => r.Idpersmedecin == _medecinSelected.Idpers)
                         .ToList();

                     Consultations = new ObservableCollection<Consultation>(
                         _cabinetContext.Consultations
                             .Where(c => c.Rendezvou.Idpersmedecin == _medecinSelected.Idpers)
                             .ToList());
                 }
                 else
                 {
                     RDVs = new List<Rendezvou>();
                     Consultations = new ObservableCollection<Consultation>();
                 }
             }
         }

         private List<Rendezvou>? _rdvs;
         public List<Rendezvou> RDVs
         {
             get => _rdvs ?? new();
             set
             {
                 _rdvs = value;
                 OnPropertyChanged();
             }
         }

         private Rendezvou? _rdvSelected;
         public Rendezvou? RDVSelected
         {
             get => _rdvSelected;
             set
             {
                 _rdvSelected = value;
                 OnPropertyChanged();
             }
         }

         private ObservableCollection<Consultation> _consultations = new();
         public ObservableCollection<Consultation> Consultations
         {
             get => _consultations;
             set
             {
                 _consultations = value;
                 OnPropertyChanged();
             }
         }

         private Consultation? _consultationSelected;
         public Consultation? ConsultationSelected
         {
             get => _consultationSelected;
             set
             {
                 _consultationSelected = value;
                 OnPropertyChanged();
             }
         }

         public bool IsEditable { get; set; }

         public ICommand CommandMedecinSave { get; set; }
         public ICommand CommandMedecinDelete { get; set; }
         public ICommand CommandMedecinSearch { get; set; }
         public ICommand CommandMedecinCancel { get; set; }
         public ICommand CommandMedecinNew { get; set; }
         public ICommand CommandMedecinEdit { get; set; }

         private void ReloadConsultations()
         {
             Consultations.Clear();
             if (MedecinSelected is null) return;

             var items = _cabinetContext.Consultations
                 .Where(c => c.Rendezvou.IdpersmedecinNavigation == MedecinSelected)
                 .ToList();

             foreach (var c in items)
                 Consultations.Add(c);
         }

         private void ActionMedecinSave()
         {
             *//*    Medecin? existing = _cabinetContext.Medecins
                     .FirstOrDefault(x => x.Idpers == MedecinSelected.Idpers);

                 if (existing == null)
                 {
                     Personne pers = new Personne()
                     {
                         Nompers = MedecinSelected.IdpersNavigation?.Nompers,
                         Prenompers = MedecinSelected.IdpersNavigation?.Prenompers,
                         Telpers = MedecinSelected.IdpersNavigation?.Telpers,
                         Rolepers = "Medecin",
                         Emailpers = MedecinSelected.IdpersNavigation?.Emailpers,
                         Datecreation = DateTime.Now,
                         Medecin = MedecinSelected
                     };

                     _cabinetContext.Personnes.Add(pers);
                     _cabinetContext.SaveChanges();
                 }
                 else
                 {
                     _cabinetContext.Medecins.Update(existing);
                     _cabinetContext.SaveChanges();
                 }

                 IsEditable = false;
                 Medecins = _cabinetContext.Medecins.ToList();*//*



             if (MedecinSelected == null)
             {
                 return;
             }

             try
             {
                 // Sécurité : si l’objet Personne n’existe pas encore
                 if (MedecinSelected.IdpersNavigation == null)
                 {
                     MedecinSelected.IdpersNavigation = new Personne();
                 }

                 // Récupération sécurisée de l’ID (0 s’il est vide)
                 var id = MedecinSelected.Idpers;

                 Medecin? existing = _cabinetContext.Medecins
                     .AsEnumerable()
                     .FirstOrDefault(x => x.Idpers == id);

                 if (existing == null)
                 {
                     // Création d'une nouvelle Personne liée au médecin
                     var pers = new Personne
                     {
                         Nompers = MedecinSelected.IdpersNavigation.Nompers,
                         Prenompers = MedecinSelected.IdpersNavigation.Prenompers,
                         Telpers = MedecinSelected.IdpersNavigation.Telpers,
                         Rolepers = "Medecin",
                         Emailpers = MedecinSelected.IdpersNavigation.Emailpers,
                         Datecreation = DateTime.Now,
                         Medecin = MedecinSelected
                     };

                     _cabinetContext.Personnes.Add(pers);

                   *//*  lastDoctor
                     Connexion con = new Connexion(){
                         Idpers = lastDoctor.IdpersNavigation;
                         Idpers = lastDoctor.Idpers;
                         Logincon=$"{lastDoctor}"
 *//*
                 }
                 else
                 {
                     // Mise à jour des infos
                     existing.IdpersNavigation.Nompers = MedecinSelected.IdpersNavigation.Nompers;
                     existing.IdpersNavigation.Prenompers = MedecinSelected.IdpersNavigation.Prenompers;
                     existing.IdpersNavigation.Telpers = MedecinSelected.IdpersNavigation.Telpers;
                     existing.IdpersNavigation.Emailpers = MedecinSelected.IdpersNavigation.Emailpers;
                     existing.Specmedecin = MedecinSelected.Specmedecin;

                     _cabinetContext.Medecins.Update(existing);
                 }

                 _cabinetContext.SaveChanges();

                 IsEditable = false;
                 Medecins = _cabinetContext.Medecins
                     .Include(m => m.IdpersNavigation) // pour rafraîchir les infos Personne liées
                     .ToList();

             }
             catch (Exception ex)
             {
                 File.AppendAllText("log.txt", $"[{DateTime.Now}] Erreur sauvegarde médecin : {ex}\n");
             }




         }

         private void ActionMedecinNew()
         {
             MedecinSelected = new Medecin
             {
                 IdpersNavigation = new Personne()
             };
             IsEditable = true;
             OnPropertyChanged(nameof(MedecinSelected));
             OnPropertyChanged(nameof(IsEditable));
         }

         private void ActionMedecinDelete()
         {
             if (MedecinSelected == null) return;

             _cabinetContext.Medecins.Remove(MedecinSelected);
             _cabinetContext.SaveChanges();

             Medecins = _cabinetContext.Medecins.ToList();
             MedecinSelected = null;
         }

         private bool CanActionMedecinDelete() => true;
         private bool CanActionMedecinSave() => true;

         private void ActionMedecinEdit()
         {
             if (MedecinSelected != null)
                 IsEditable = true;
         }
         private bool CanActionMedecinEdit() => MedecinSelected != null && !IsEditable;

         private void ActionMedecinCancel()
         {
             IsEditable = false;
             Medecins = _cabinetContext.Medecins.ToList();
         }

         private void ActionMedecinSearch()
         {
             if (string.IsNullOrWhiteSpace(NomSearch))
                 Medecins = _cabinetContext.Medecins.ToList();
             e
                 lse
                 Medecins = _cabinetContext.Medecins
                     .Where(m => m.IdpersNavigation.Nompers.Contains(NomSearch))
                     .ToList();
         }

         public event PropertyChangedEventHandler? PropertyChanged;
         private void OnPropertyChanged([CallerMemberName] string? prop = null)
             => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(prop));
     }*/

    internal class MedecinsViewModel :  INotifyPropertyChanged
    {
        CabinetContext? _cabinetmartinContext;

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

        private List<Medecin>? _medecins;
        public List<Medecin> Medecins
        {
            get => _medecins ?? new();
            set
            {
                _medecins = value;
                OnPropertyChanged();
            }
        }

        private Medecin? _medecinSelected;
        public Medecin MedecinSelected
        {
            get => _medecinSelected ?? new();
            set
            {
                _medecinSelected = value;
                OnPropertyChanged();
                ReloadConsultations();
            }
        }


        private List<Rendezvou>? _rDVs;
        public List<Rendezvou> RDVs
        {
            get => _rDVs ?? new();
            set
            {
                _rDVs = value;
                OnPropertyChanged();
            }
        }

        private Rendezvou? _rDVSelected;
        public Rendezvou RDVSelected
        {
            get => _rDVSelected ?? new();
            set
            {
                _rDVSelected = value;
                OnPropertyChanged();
            }
        }
        public ObservableCollection<Consultation> Consultations { get; } = new();
        private List<Consultation>? _consultations;

        private Consultation? _consultationSelected;
        public Consultation ConsultationSelected
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
                .Where(c => c.Rendezvou != null
                         && c.Rendezvou.IdpersmedecinNavigation != null
                         && c.Rendezvou.IdpersmedecinNavigation.Idpers == MedecinSelected.Idpers) // compare par Id
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
            MedecinSelected = new Medecin()
            {
                IdpersNavigation = new Personne() { Rolepers = "Medecin" }


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

            Medecin? _medecin = Medecins.Where(x => x.Idpers == MedecinSelected.Idpers).FirstOrDefault();
            if (_medecin == null)
            {
                //MedecinSelected.IdpersMedecinNavigation.Rolepers = ;
                Personne _personne = new Personne()
                {
                    Nompers = MedecinSelected.IdpersNavigation?.Nompers,
                    Prenompers = MedecinSelected.IdpersNavigation?.Prenompers,
                    Telpers = MedecinSelected.IdpersNavigation?.Telpers,
                    Rolepers = "Medecin",
                    Emailpers = MedecinSelected?.IdpersNavigation?.Emailpers,
                    Datecreation = DateTime.Now,
                    Medecin = MedecinSelected

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


        public MedecinsViewModel()
        {
            _cabinetmartinContext = new CabinetContext();
            List<Connexion> lc = _cabinetmartinContext.Connexions.ToList();
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

