using System;
using System.Collections.Generic;
using System.Linq;
using Horoazhon.Domain.Models;

using System.Text;
using System.Threading.Tasks;

namespace Horoazhon.Services.User
{
    public static class UserService
    {

        public static string UserName { get; set; } = "Invité";
        public static string UserRole { get; set; } = "User";
        public static Personne? AUser { get; set; } = null;
        public static bool IsAuthenticated { get; set; } = false;
     /*    public static AppUser? AUser { get; set; }
       public static void SetUser(AppUser user)
        {
            AUser = user;
        }

        public static void Clear()
        {
            AUser = null;
        }
    }

    public class AppUser
    {
        public Medecin Medecin { get; set; }
        public string? Email { get; set; }
        public string? Role { get; set; }

        public AppUser(Medecin medecin, string? email = null, string? role = null)
        {
            Medecin = medecin;
            Email = email;
            Role = role;
        }*/
    }
}
