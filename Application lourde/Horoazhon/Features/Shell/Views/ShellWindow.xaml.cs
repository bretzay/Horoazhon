using Horoazhon.Features.Dashboard.Views;
using Horoazhon.Features.Personnes.Views;
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
          NavigationViewItem elem = sender.SelectedItem as NavigationViewItem; //Or, ?? sert � fournir une valeur par d�faut si la premi�re est null, tandis que as sert � faire un cast s�curis�.


            switch (elem!.Tag)
            {
                case "Tableau":
                    Root.Navigate(typeof(DashboardPage));
                    break;
                case "Agents":
                    Root.Navigate(typeof(AgentPage));
                    break;
                case "Clients":
                    Root.Navigate(typeof(ClientPage));
                    break;
            }
        
        }
    }
}
