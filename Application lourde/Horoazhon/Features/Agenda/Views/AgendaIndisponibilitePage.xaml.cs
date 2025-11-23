using Horoazhon.Domain.Models;
using Horoazhon.Services.Agenda;
using Horoazhon.Features.Agenda.ViewModel;
using Horoazhon.Features.Consultations.Views;
using Horoazhon.Features.Rdvs.Views;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Controls.Primitives;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Navigation;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;

namespace Horoazhon.Features.Agenda.Views
{

    public sealed partial class AgendaIndisponibilitePage : Page
    {
        AgendaViewModel agendaViewModel { get; set; }
        public AgendaIndisponibilitePage()
        {
            InitializeComponent();
            agendaViewModel = new AgendaViewModel();
            DataContext = agendaViewModel;
        }

        private async void MoreInfoClick(object sender, RoutedEventArgs e)
        {
            SlotService? elem = (sender as Button)!.DataContext as SlotService;
            ContentDialog contentDialog;
            if (elem.StartTime.Hour > 12 && elem.EndTime.Hour < 13)
            {
                contentDialog = new ContentDialog()
                {
                    Title = "Slot",
                    MinWidth = 1000,
                    MinHeight = 500,
                    XamlRoot = this.XamlRoot,
                    Content = "créneau indisponible",
                    PrimaryButtonText = "Fermer",
                    DataContext = elem,

                };
            }
            contentDialog = new ContentDialog()
            {
                Title = "Slot",
                MinWidth = 1000,
                MinHeight = 500,
                XamlRoot = this.XamlRoot,
               // Content = new RdvResumeIndisponibiliteControl(elem!),
                PrimaryButtonText = "Fermer",
                DataContext = elem,

            };
            var result = await contentDialog?.ShowAsync();


            // L’utilisateur a fermé : on revient à l’agendaindisponible
            agendaViewModel.ShowAgenda();
            Frame.Navigate(typeof(AgendaIndisponibilitePage));




        }
        private void ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var elem = (sender as ComboBox)!.SelectedItem as Medecin;
            agendaViewModel.MedecinSelected = elem!;
            agendaViewModel.ShowAgenda();
        }
    }
}
