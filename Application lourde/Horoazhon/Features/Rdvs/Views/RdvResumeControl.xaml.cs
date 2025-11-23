using Horoazhon.Features.Clients.Views;
using Horoazhon.Features.Consultations.Views;
using Horoazhon.Features.Rdvs.ViewModel;
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
using System.Runtime.InteropServices.WindowsRuntime;
using System.Runtime.Intrinsics.Arm;
using Windows.Foundation;
using Windows.Foundation.Collections;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace Horoazhon.Features.Rdvs.Views
{
    public sealed partial class RdvResumeControl : UserControl
    {
        IRdvViewModel rvm;
        public RdvResumeControl(SlotService? ss = null)
        {
            InitializeComponent();
            rvm = new RdvsViewModel();
            if (ss != null) rvm.RdvSlotService = ss;
            DataContext = rvm;
        }
        private async void BtnConsultationDetail_Click(object sender, RoutedEventArgs e)
        {
            if (rvm.RdvClientselected != null)
                // Called by copy/paste windowframe instead of root ?
                // (App.WindowSelected as ShellWindow)!.WindowFrame.Navigate(typeof(ConsultationPage)); 
                (App.WindowSelected as ShellWindow)!.Root.Navigate(typeof(ConsultationPage)); 
            else
            {
                ContentDialog cd = new ContentDialog()
                {
                    Title = "Fash Info!",
                    Content = "Veuillez enregistrer un Client pour ouvrir une consultation!",
                    XamlRoot = this.XamlRoot
                };
                await cd.ShowAsync();
            }

        }
    }
}
