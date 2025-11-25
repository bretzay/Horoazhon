using Horoazhon.Domain.Models;
using Microsoft.UI;
using Microsoft.UI.Xaml.Media;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Horoazhon.Features.Shell.Views;
using Horoazhon.Features.Agenda.Views;
using Horoazhon.Features.Agenda.ViewModel;


namespace Horoazhon.Services.Agenda
{
    public class AgendaService
    {
        DateOnly? before, after, actualy, copieactualy;
        public Agent? MedecinSelected { get; set; }
        int? move = 0;
        ObservableCollection<SlotService>? Slots;
        public void Init()
        {
            DateOnly today;
            int delta;
            today = DateOnly.FromDateTime(DateTime.Today);
            delta = ((int)today.DayOfWeek - (int)DayOfWeek.Monday + 7) % 7;
            actualy = today.AddDays(-delta);

        }

        public void MoveSlotWeek(int x = 0)
        {
            Init();
            move += x * 7;
            actualy = actualy?.AddDays(move ?? 0);
            before = actualy?.AddDays(-7);
            after = actualy?.AddDays(+7);
        }

        public List<string> SlotLabel()
        {
            List<string> liste = new List<string>();
            TimeOnly time = new TimeOnly(8, 0);
            while (time < new TimeOnly(19, 0)) 



            {
                liste.Add($"{time.ToString("HH:mm")}");
                time = time.AddMinutes(30);
            }
            return liste;
        }
        public ObservableCollection<SlotService>? SlotDay()
        {
            Slots = new ObservableCollection<SlotService>();
            // Jour courant en UTC
            var d = copieactualy ?? DateOnly.FromDateTime(DateTime.UtcNow);
            // 08:00 UTC ce jour-là
            DateTimeOffset dateStart = new DateTimeOffset(d.Year, d.Month, d.Day, 8, 0, 0,TimeSpan.Zero);
            var list = MedecinSelected!.Rendezvous.ToList(); // Datedebutrdv est un DateTimeOffset depuis SQL
        for (int i = 0; i < 22; i++)
            {
                // comparaison en UTC 
                var rdv = list.FirstOrDefault(x => x.Datedebutrdv.ToUniversalTime() == dateStart); // dateStart est déjà UTC
 string statut = (rdv == null || rdv.Disponibilite == true) ? "disponible" :
"non disponible";
                if (i == 8 || i == 9)
                {
                    Slots!.Add(new SlotService
                    {
                        Statut = "non disponible",
                        OneMedecin =
                   MedecinSelected,
                        IsEditable = false,
                        BackgroundColor = new SolidColorBrush(Colors.Red)
                    });
                }
                else
                {
                    Slots!.Add(new SlotService
                    {
                        RDV = rdv,
                        StartTime = dateStart,
                        EndTime = dateStart.AddMinutes(30),
                        Statut = (rdv != null && rdv.IdpersClientNavigation != null) ? $"réservation :  { rdv.IdpersClientNavigation.IdpersNavigation.Nompers }{ rdv.IdpersClientNavigation.IdpersNavigation.Prenompers }": statut,
                        OneMedecin = MedecinSelected,
                        IsEditable = rdv?.Disponibilite ?? true,
                        BackgroundColor = rdv == null ? new SolidColorBrush(Colors.Blue) : Colored(rdv)
                    });
                    dateStart = dateStart.AddMinutes(30);
                }
            }
            return Slots;
        }
        public Dictionary<string, List<SlotService>>? SlotWeek(int x = 0)
        {
            MoveSlotWeek(x);
            Dictionary<string, List<SlotService>> SlotWeek = new Dictionary<string, List<SlotService>>();
            copieactualy = actualy;
            for (int j = 0; j < 5; j++)
            {

                List<SlotService>? liste = SlotDay()!.ToList();
                SlotWeek!.Add($"{copieactualy?.ToString("dddd")} \n { copieactualy!.Value.Day}/{ copieactualy.Value.Month}/{ copieactualy.Value.Year}",liste); copieactualy = copieactualy?.AddDays(1);
            }
            return SlotWeek;
        }

        public SolidColorBrush Colored(RendezVous? rdv)
        {
            if (!rdv?.Disponibilite ?? true)
            {
                return new SolidColorBrush(Colors.Red);
            }
            if (rdv?.IdpersmedecinNavigation != null)
            {
                return new SolidColorBrush(Colors.Green);
            }

            return new SolidColorBrush(Colors.Yellow);
        }
    }


   


}
