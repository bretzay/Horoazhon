using Horoazhon.Domain.Models;
using Horoazhon.Features.Agenda.ViewModel;
using Horoazhon.Features.Consultations.Views;
using Horoazhon.Features.Rdvs.ViewModel;
using Horoazhon.Features.Rdvs.Views;
using Horoazhon.Features.Shell.Views;
using Horoazhon.Services.Agenda;
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
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Foundation.Collections;



namespace Horoazhon.Features.Agenda.Views
{

    public sealed partial class AgendaPage : Page
    {
        AgendaViewModel agendaViewModel { get; set; }
        public AgendaPage()
        {
            InitializeComponent();
            agendaViewModel=new AgendaViewModel();
            DataContext = agendaViewModel;
        }

       
        
        private async void MoreInfo(object sender, SelectionChangedEventArgs e)
        {

            if (sender is not ListView lv) //2117
                return;

            if (lv.SelectedItem is not SlotService elem)
                return;


            //var elem = (sender as ListView)!.SelectedItem as SlotService;
            ContentDialog contentDialog = new ContentDialog()
            {
                Title = "Slot",
                XamlRoot = this.XamlRoot,
                PrimaryButtonText = "Fermer",
                Content = sender.ToString()
            };
            await contentDialog?.ShowAsync();
        }

        private async void MoreInfoClick(object sender, RoutedEventArgs e)
        {
            SlotService? elem = (sender as Button)!.DataContext as SlotService;

            ContentDialog contentDialog = new ContentDialog()
            {
                Title = "Informations du créneau",
                MinWidth = 1000,
                MinHeight = 500,
                XamlRoot = this.XamlRoot,
              //  Content = new Rdvs.Views.RdvResumeControl(elem),
                PrimaryButtonText = "Fermer",
                SecondaryButtonText = "Ouvrir la consultation",
                DataContext = elem,
                


            };
            var result = await contentDialog?.ShowAsync();
            if (result == ContentDialogResult.Secondary && elem!=null )
            {
               
                    var rdv = elem; // param à passer
                    Frame.Navigate(typeof(RdvPage), elem);

                    // (App.WindowSelected as ShellWindow)?.WindowFrame?.Navigate(typeof(VisitePage), rdv);
                
            }
            else
            {
                // L’utilisateur a fermé : on revient à l’agenda
                agendaViewModel.ShowAgenda();
                Frame.Navigate(typeof(AgendaPage));
            }
        }


        private void ListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {

        }
        
        private void ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var elem = (sender as ComboBox)!.SelectedItem as Agent;
            agendaViewModel.MedecinSelected = elem!;
            //agendaViewModel.ShowAgenda();
        }
    }
}
