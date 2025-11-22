using Horoazhon.Domain.Models;
using Horoazhon.Services.Agenda;
using Horoazhon.Services.Command;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Agenda.ViewModel
{
    public class AgendaViewModel : INotifyPropertyChanged, IAgendaViewModel
    {
        public event PropertyChangedEventHandler? PropertyChanged;
        CabinetContext? HoroazhonContext = new();
        private List<Medecin>? _medecins;
        private Medecin? _medecinSelected;
        private string? _nomMedecin;        
        private string? _lundiLabel;
        private string? _mardiLabel;
        private string? _mercrediLabel;
        private string? _jeudiLabel;
        private string? _vendrediLabel;
        private List<SlotService>? _lundiList;
        private List<SlotService>? _mardiList;
        private List<SlotService>? _mercrediList;
        private List<SlotService>? _jeudiList;
        private List<SlotService>? _vendrediList;
        private SlotService? _slotSelected;
        private bool _isEditable = true;
        
        public AgendaService? AgendaServiceMedecin { get; set; }

        public List<Medecin> Medecins
        {
            set
            {
                _medecins = value;
                OnPropertyChanged();
            }
            get => _medecins??new();
        }

        public Medecin MedecinSelected
        {
            set
            {
                /*       if (ReferenceEquals(_medecinSelected, value)) return;
                       _medecinSelected = value;

                           AgendaServiceMedecin!.MedecinSelected = _medecinSelected;
                           ShowAgenda();                  // ne bouge pas la semaine
                       OnPropertyChanged();
         */


                if (value == null || ReferenceEquals(_medecinSelected, value))
                    return;

                _medecinSelected = value;

                if (AgendaServiceMedecin != null)
                {
                    AgendaServiceMedecin.MedecinSelected = _medecinSelected;
                    AgendaServiceMedecin.MoveSlotWeek(0); // recharge proprement
                    ShowAgenda();
                }

                OnPropertyChanged();


            }
            get {
                
                
                return _medecinSelected ?? new(); 
            }
            }
        public string NomMedecin 
        {
            set
            {
                _nomMedecin = $"Dr. {_medecinSelected!.IdpersNavigation.Nompers}";
                
                OnPropertyChanged();
            }
            get => _nomMedecin ??"";
        }

        public List<string> SlotLabelList => AgendaServiceMedecin!.SlotLabel();        

        public string LundiLabel {
            get => _lundiLabel??"";
            set
            {
                _lundiLabel = value;
                OnPropertyChanged();
            }
        }
        public string MardiLabel {
            get => _mardiLabel??"";
            set
            {
                _mardiLabel = value;
                OnPropertyChanged();
            }
        }
        public string MercrediLabel { 
            get => _mercrediLabel??"";
            set
            {
                _mercrediLabel = value;
                OnPropertyChanged();
            }
        }
        public string JeudiLabel { 
            get => _jeudiLabel??"";
            set { 
                _jeudiLabel = value;
                OnPropertyChanged();

            }
        }
        public string VendrediLabel {
            get => _vendrediLabel??"";
            set { _vendrediLabel = value;
            OnPropertyChanged();
            }
        }
        public List<SlotService> LundiList
        {
            set
            {
                _lundiList = value;
                OnPropertyChanged();
            }
            get => _lundiList??new();
        }
        public List<SlotService> MardiList {
            set
            {
                _mardiList = value;
                OnPropertyChanged();
            }
            get => _mardiList ?? new();
        }
        public List<SlotService> MercrediList {
            set
            {
                _mercrediList = value;
                OnPropertyChanged();
            }
            get => _mercrediList ?? new();
        }
        public List<SlotService> JeudiList {
            set
            {
                _jeudiList = value;
                OnPropertyChanged();
            }
            get => _jeudiList ?? new();
        }
        public List<SlotService> VendrediList {
            set
            {
                _vendrediList = value;
                OnPropertyChanged();
            }
            get => _vendrediList ?? new();
        }
        public SlotService SlotSelected {
            set
            {
                _slotSelected = value;
                OnPropertyChanged();
            }
            get => _slotSelected ?? new();
        }

        /// <summary>
        /// Invocation de PropertyChanged
        /// </summary>
        /// <param name="n"></param>        
        private void OnPropertyChanged([CallerMemberName] string? n = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));
        public ICommand GoCommand { get; set; } 

        public ICommand BackCommand { get; set; }
        private bool _isEnabledConsultation;
        public bool IsEnabledConsultation(SlotService slot) {
            if (slot.RDV != null && slot.RDV.IdpersmedecinNavigation != null)
                return true;
            
            return false;
        }
        
        public void GoAction()
        {
            AgendaServiceMedecin!.MoveSlotWeek(-1);
            ShowAgenda();
        }

        public void BackAction()
        {
            AgendaServiceMedecin!.MoveSlotWeek(1);
            ShowAgenda();
        }
        public AgendaViewModel()
        {
            Medecins = HoroazhonContext.Medecins.ToList();
            AgendaServiceMedecin = new();






            // MedecinSelected = Medecins[0];  


            _medecinSelected = Medecins.FirstOrDefault();

            if (_medecinSelected != null)
                AgendaServiceMedecin.MedecinSelected = _medecinSelected;
            AgendaServiceMedecin.MoveSlotWeek(0);
            ShowAgenda();




            GoCommand = new RelayCommand(_ => GoAction());
            BackCommand = new RelayCommand(_ => BackAction());
        }

        public void ShowAgenda()
        {
            if (AgendaServiceMedecin is null) return;            
            NomMedecin = $" Dr. {MedecinSelected.IdpersNavigation.Nompers}";
            AgendaServiceMedecin!.MoveSlotWeek();
            int i = 0;
            if (AgendaServiceMedecin != null)
            {
                foreach (var item in AgendaServiceMedecin!.SlotWeek()!)
                {
                    switch (i)
                    {
                        case 0:
                            {
                                LundiLabel = item.Key;
                                LundiList = item.Value;
                                break;
                            }
                        case 1:
                            {
                                MardiLabel = item.Key;
                                MardiList = item.Value;
                                break;
                            }
                        case 2:
                            {
                                MercrediLabel = item.Key;
                                MercrediList = item.Value;
                                break;
                            }
                        case 3:
                            {
                                JeudiLabel = item.Key;
                                JeudiList = item.Value;
                                break;
                            }
                        case 4:
                            {
                                VendrediLabel = item.Key;
                                VendrediList = item.Value;
                                break;
                            }
                    }
                    i++;
                }
            }
            
        }
    }
}
