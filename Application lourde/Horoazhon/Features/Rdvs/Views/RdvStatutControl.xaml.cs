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

public sealed partial class RdvStatutControl : UserControl
{
    public string? Text { get; set; }
    public RdvStatutControl()
    {
        InitializeComponent();
    }
    private void ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {

        Text = (CbStatut.SelectedItem as ComboBoxItem).Content.ToString();
        ContentDialog contentDialog = new()
        {
            Title = "ok",
            XamlRoot = this.XamlRoot,
            Content = Text
        };
        contentDialog?.ShowAsync();

    }
}
