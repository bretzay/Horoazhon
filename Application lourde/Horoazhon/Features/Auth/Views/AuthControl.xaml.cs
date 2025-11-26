using Horoazhon.Features.Auth.ViewModel;
using Horoazhon.Features.Auth.Views;

using Horoazhon.Features.Medecins.ViewModel;
using Horoazhon.Features.Shell.Views;
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

namespace Horoazhon.Features.Auth.Views
{
    public sealed partial class AuthControl : UserControl
    {
        AuthViewModel authViewModel;
        public AuthControl()
        {
            InitializeComponent();
            authViewModel = new AuthViewModel();
            DataContext = authViewModel;
        }

        private async void BtnValider_Click(object sender, RoutedEventArgs e)
        {
            if (authViewModel.VerifiedPin())
            {


                App.Utilisateur();

            }
            else
            {
                await new ContentDialog
                {
                    Title = "Authentification",
                    Content = "Code invalide.",
                    XamlRoot = this.XamlRoot,
                    CloseButtonText = "Ok"
                }.ShowAsync();
            }
        }

        private void BtnValiderFake_Click(object sender, RoutedEventArgs e)
        {
            authViewModel.ActionLogin();
            App.Utilisateur();
        }
    }





}

