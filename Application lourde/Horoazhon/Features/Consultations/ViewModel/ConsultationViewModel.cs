using Horoazhon.Domain.Models;
using Horoazhon.Services.Command;
using Horoazhon.Services.Print;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using System.Windows.Input;
using Windows.System;

namespace Horoazhon.Features.Consultations.ViewModel
{
    public class ConsultationViewModel : IConsultationViewModel, INotifyPropertyChanged
    {
        private CabinetContext _cabinetContext;
        private Consultation _consultationSelected = new();
        private Rendezvou? _rdvSelected;

        public ConsultationViewModel(Rendezvou? elem = null)
        {
            _cabinetContext = new CabinetContext();

            if (elem != null)
            {
                ReloadConsultationSelected(elem);
            }
          

                else
                {
                    // Vérifie que le médecin est bien chargé
                    var idMedecin = Services.User.UserService.AUser?.Medecin?.Idpers;

                    if (idMedecin != null)
                    {
                        ReloadConsultationSelected(new Rendezvou()
                        {
                            Idpersmedecin = idMedecin.Value
                        });
                    }
                    else
                    {
                        // Aucun médecin connecté → initialisation par défaut
                        _consultationSelected = new Consultation()
                        {
                            Indisponibilite = false,
                            Statutcons = "libre",
                            Prixcons = 25.00m
                        };
                    }
                }

                CommandConsultationSave = new RelayCommand(_ => ActionConsultationSave());
                CommandConsultationCancel = new RelayCommand(_ => ActionConsultationCancel());
                CommandPrint = new RelayCommand(async _ => await ActionPrint());
                CommandTeleconsultation = new RelayCommand(async _ => await ActionTeleconsultation());
            }


               /* ReloadConsultationSelected(new Rendezvou()
                {
                    Idpersmedecin = Services.User.User.AUser.Medecin.Idpers
                }

                    );

                CommandConsultationSave = new RelayCommand(_ => ActionConsultationSave());
                CommandConsultationCancel = new RelayCommand(_ => ActionConsultationCancel());
                CommandPrint = new RelayCommand(async _ => await ActionPrint());
                CommandTeleconsultation = new RelayCommand(async _ => await ActionTeleconsultation());
            }*/

            #region Propriétés principales
        public Consultation ConsultationSelected
        {
            get => _consultationSelected;
            set { _consultationSelected = value; OnPropertyChanged(); }
        }

        public string ConsultationDate { get; private set; } = "";
        public string ConsultationMedecinNom { get; set; } = "";
        public string ConsultationClientNom { get; set; } = "";
        public string? ConsultationMotif { get; set; }

        public List<Consultation>? Consultations { get; set; } = new();
        public List<Rendezvou>? Rdvs { get; set; } = new();
        #endregion

        #region Commandes
        public ICommand CommandConsultationSave { get; }
        public ICommand CommandConsultationCancel { get; }
        public ICommand CommandPrint { get; }
        public ICommand CommandTeleconsultation { get; }
        #endregion

        public event PropertyChangedEventHandler? PropertyChanged;
        private void OnPropertyChanged([CallerMemberName] string? name = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));

        public void ReloadConsultationSelected(Rendezvou? elem)
        {
            // var c = elem!.Consultations;

            if (elem == null)
            {
                _consultationSelected = null;
                return;
            }
            var c = elem.Consultations.FirstOrDefault();


            if (c == null)
            {
                _consultationSelected = new Consultation()
                {
                    Indisponibilite = false,
                    Statutcons = "libre",
                    Prixcons = 25.00m
                };
            }
            else { _consultationSelected = c; }
            OnPropertyChanged(nameof(ConsultationSelected));


            try
            {
                _consultationSelected.Rendezvou = elem;
                _consultationSelected.Datedebutrdv = elem.Datedebutrdv;
                _consultationSelected.Datefinrdv = elem.Datefinrdv;
                _consultationSelected.Idpersmedecin = elem.Idpersmedecin;

                ConsultationDate = $"{_consultationSelected.Datedebutrdv:dd/MM/yy HH:mm} -> {_consultationSelected.Datefinrdv:dd/MM/yy HH:mm}";
                ConsultationMedecinNom = $"Dr. {_consultationSelected.Rendezvou.IdpersmedecinNavigation.IdpersNavigation.Nompers}";
                ConsultationClientNom = $"{_consultationSelected.Rendezvou.IdpersClientNavigation!.IdpersNavigation.Nompers}";
                _consultationSelected.Motifcons = _consultationSelected.Rendezvou.Commentairerdv;
                ConsultationMotif = _consultationSelected.Motifcons;

                ConsultationSelected = _consultationSelected;

                _cabinetContext = new CabinetContext();
                Consultations = _cabinetContext.Consultations
                    .Where(x => x.Idpersmedecin == _consultationSelected!.Idpersmedecin &&
                                x.Rendezvou.IdpersClient == _consultationSelected.Rendezvou.IdpersClient)
                    .ToList();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Erreur: {ex.Message}");
            }
            finally
            {
                Rdvs = _cabinetContext.Rendezvous
                    .Where(x => x.Idpersmedecin == _consultationSelected!.Idpersmedecin &&
                                x.Datedebutrdv.Month == 10 &&
                                x.Datedebutrdv.Year == 2025 &&
                                x.Datedebutrdv.Day == 1)
                    .ToList();
            }
        }

        #region Actions principales
        private void ActionConsultationSave()
        {
            try
            {
                if (_consultationSelected == null) return;

                if (_consultationSelected.Idcons == 0)
                    _cabinetContext.Consultations.Add(_consultationSelected);
                else
                    _cabinetContext.Consultations.Update(_consultationSelected);

                _cabinetContext.SaveChanges();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Erreur de sauvegarde : {ex.Message}");
            }
        }

        private void ActionConsultationCancel()
        {
            if (_rdvSelected != null)
                ReloadConsultationSelected(_rdvSelected);
        }

        private async Task ActionTeleconsultation()
        {
            var url = ConsultationSelected?.Lienweb?.Trim();
            if (Uri.TryCreate(url, UriKind.Absolute, out var uri))
                await Launcher.LaunchUriAsync(uri);
        }

        private async Task ActionPrint()
        {
            try
            {
                App.MainHwnd = WinRT.Interop.WindowNative.GetWindowHandle(App.WindowSelected);
                (App.WindowSelected ?? new MainWindow()).Closed += (_, __) => App.MainHwnd = 0;
                var printer = OrdonnancePrinter.GetOP(App.WindowSelected!);
                await printer.PrintAsync(
                    ConsultationSelected.Ordonnancecons ?? " ",
                    ConsultationMedecinNom,
                    ConsultationClientNom,
                    " ");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Erreur impression : {ex.Message}");
            }
        }
        #endregion
    }
}
