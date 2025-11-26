using Horoazhon.Features.Agenda.Views;
using Horoazhon.Features.Visite.Views;
using Horoazhon.Features.Dashboard.Views;
using Horoazhon.Features.Medecins.Views;
using Horoazhon.Features.Clients.Views;
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

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace Horoazhon.Features.Shell.Views
{
    /// <summary>
    /// An empty window that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class ShellWindow : Window
    {
        public Frame WindowFrame => Root;
        public ShellWindow()
        {
            InitializeComponent();
        }

       private void NavigationView_SelectionChanged(NavigationView sender, NavigationViewSelectionChangedEventArgs args)
        {
          NavigationViewItem elem = sender.SelectedItem as NavigationViewItem; //Or, ?? sert à fournir une valeur par défaut si la première est null, tandis que as sert à faire un cast sécurisé.


            switch (elem!.Tag)
            {
                case "Tableau":
                    Root.Navigate(typeof(DashboardPage));
                    break;
                case "Medecins":
                    Root.Navigate(typeof(AgentPage));
                    break;
                case "Agenda":
                    Root.Navigate(typeof(AgendaPage));
                    break;
                case "Clients":
                    Root.Navigate(typeof(ClientPage));
                    break;
                case "Visite":
                    Root.Navigate(typeof(VisitePage));
                    break;
                
            }
        
        }
    }
}
