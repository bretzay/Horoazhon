using Microsoft.UI.Dispatching;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Printing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Graphics.Printing;
using WinRT.Interop;

namespace Horoazhon.Services.Print
{
    
        public sealed class OrdonnancePrinter
        {
            public static OrdonnancePrinter? InstancePrint = null;
            // ====== Paramètres "cabinet" (tu peux les modifier ici) ======
            private const string CabinetNom = "Cabinet Martin";
            private const string CabinetAdresse1 = "7 rue des archives";
            private const string CabinetAdresse2 = "53 000 Laval";
            private const string CabinetTel = "Tél.: 0243999999";
            private const string CabinetEmail = "Email: Horoazhononeline53X@gmail.com";
            // Ligne pied de page (adresse + contact)
            private static string CabinetFooterLine =>
            $"{CabinetNom} — {CabinetAdresse1} — {CabinetAdresse2} — {CabinetTel} —{CabinetEmail }";
 // ====== Champs ======
 private readonly IntPtr _hwnd;
        private readonly DispatcherQueue _dispatcher;
        private PrintDocument _doc;
        private IPrintDocumentSource _docSrc;
        private List<UIElement> _pages;
        private List<TextBlock> _footers;
        private string _texteLibre;
        private string _nomMedecin;
        private string _ClientNom;
        private string _ClientPrenom;
        private DateTime _ClientDob;
        private OrdonnancePrinter(Window window)
        {
            if (window is null) throw new ArgumentNullException(nameof(window));
            _dispatcher = window.DispatcherQueue ?? throw new
           InvalidOperationException("DispatcherQueue indisponible.");
            _hwnd = WindowNative.GetWindowHandle(window);
            if (_hwnd == IntPtr.Zero) throw new InvalidOperationException("HWND invalide (fenêtre non activée ?).");
        }
        public static OrdonnancePrinter GetOP(Window window)
        {
            if (InstancePrint == null)
            {
                InstancePrint = new OrdonnancePrinter(window);
            }

            return InstancePrint;

        }
        public async Task PrintAsync(string texteLibre, string nomMedecin,
        string ClientNom, string ClientPrenom)
        {
            if (texteLibre == null || texteLibre == "") texteLibre = " ";
            // 2) S’abonner et fournir une source de document
            var printManager = PrintManagerInterop.GetForWindow(App.MainHwnd);

            var printDoc = new Microsoft.UI.Xaml.Printing.PrintDocument();
            var docSrc = printDoc.DocumentSource;
            printDoc.Paginate += (s, e2) =>
            {
                // Prépare au moins 1 page
                var page = new Grid
                {
                    Width = 793,
                    Height = 1122,
                    Padding = new Thickness(10)
                };
                var stack = new StackPanel
                {
                    Width = 703,
                    HorizontalAlignment = HorizontalAlignment.Center
                };
                stack.Children.Add(new TextBlock
                {
                    Margin = new Thickness(20, 70, 10, 0),
                    Text = "Cabinet Martin",
                    FontSize = 32,
                    TextAlignment = TextAlignment.Center
                });
                stack.Children.Add(new TextBlock
                {
                    Text = "7, rue des archives",
                    FontSize = 12,
                    TextAlignment = TextAlignment.Center
                });
                stack.Children.Add(new TextBlock
                {
                    Text = "53 000 Laval Cedex 2",
                    FontSize = 12,
                    TextAlignment = TextAlignment.Center
                });
                stack.Children.Add(new TextBlock
                {
                    Text = "Tél : 02 43 49 12 12",
                    FontSize = 12,
                    TextAlignment = TextAlignment.Center
                });
                stack.Children.Add(new TextBlock
                {
                    Text = "Email : Horoazhononline@gmail.com",
                    FontSize = 12,
                    TextAlignment = TextAlignment.Center
                });
                stack.Children.Add(new TextBlock
                {
                    Margin = new Thickness(50, 30, 0, 0),
                    Text = $"Dr. {nomMedecin} - siret : 01258562541122",
                    FontSize = 12,
                    TextAlignment = TextAlignment.Left
                });
                /*stack.Children.Add(new TextBlock
                {
                Margin = new Thickness(50, 15, 0, 0),
                Text = $"Client: {ClientNom}\nNé(e) le: {ClientDateNaissance}",
                TextAlignment = TextAlignment.Left
                });*/
                stack.Children.Add(new TextBlock
                {
                    Margin = new Thickness(20, 15, 0, 0),
                    TextAlignment = TextAlignment.Left,

                    //Margin = new Thickness(0, 0, 0, 0),
                    Text = $"{texteLibre}",
                });
                page.Children.Add(stack);
                printDoc.SetPreviewPageCount(1,
               Microsoft.UI.Xaml.Printing.PreviewPageCountType.Final);
                printDoc.SetPreviewPage(1, page);
            };
            printDoc.AddPages += (s, e2) =>
            {
                var page = new Grid
                {
                    Width = 793,
                    Height = 1122,
                    Padding = new Thickness(48)
                };
                page.Children.Add(new TextBlock
                {
                    Text = "Bonjour l’imprimante",
                    FontSize =
               32
                });
                printDoc.AddPage(page);
                printDoc.AddPagesComplete();
            };
            printManager.PrintTaskRequested += (s, e2) =>
            {
                e2.Request.CreatePrintTask("Impression WinUI 3", r => r.SetSource(docSrc));
            };
            // 3) Afficher la boîte d’impression (UI thread)
            await PrintManagerInterop.ShowPrintUIForWindowAsync(App.MainHwnd);
            //this = null;
        }

    }
}
