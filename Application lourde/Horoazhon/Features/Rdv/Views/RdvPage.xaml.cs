using Horoazhon.Features.Rdvs.ViewModel;
using Horoazhon.Domain.Models;
using Horoazhon.Features.Clients.ViewModel;
using Horoazhon.Features.Rdvs.Views;
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
using Windows.Foundation;
using Windows.Foundation.Collections;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace Horoazhon.Features.Rdvs.Views;

/// <summary>
/// An empty page that can be used on its own or navigated to within a Frame.
/// </summary>
public sealed partial class RdvPage : Page
{
    public RdvPage()
    {
        InitializeComponent();
        DataContext = new RdvsViewModel();
      
    }

    protected override void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);


        if (e.Parameter is SlotService slot)
        {
            var vm = (RdvsViewModel)DataContext;
            vm.RdvSlotService = slot;     
        }

        if (e.Parameter is RendezVous rdv)
            DataContext = new RdvsViewModel { RdvSelected = rdv };
        else
            DataContext = new RdvsViewModel();
    }

  
}
