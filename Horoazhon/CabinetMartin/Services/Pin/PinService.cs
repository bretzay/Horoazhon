using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace Horoazhon.Services.Pin
{
    internal class PinService
    {

        //Colléction clé valeur accessible par plusieurs threads
        private static readonly ConcurrentDictionary<string, (string Code, DateTimeOffset Expire)> Store
        = new();

        //Détail max de 20 minutes
        private static readonly TimeSpan Ttl = TimeSpan.FromMinutes(20);

        //Génération du code pin
        public static string CreatePin(string email, int digits = 6)
        {
            int max = (int)Math.Pow(10, digits);
            string code = RandomNumberGenerator.GetInt32(max).ToString($"D{digits}");//"123456"; 
            Store[email] = (code, DateTimeOffset.UtcNow.Add(Ttl));
            return code;
        }

        //Vérification le code Pin
        public static (bool, string) Verify(string email, string input)
        {
            var result = (false, "ok");
            if (!string.IsNullOrEmpty(input) && Store.ContainsKey(email))
            {
                var (code, date) = Store[email];
                if (DateTimeOffset.UtcNow > date)
                {
                    result.Item2 = "Code expiré";
                }
                result.Item1 = code.Equals(input) && DateTimeOffset.UtcNow < date;

            }

            return result;

        }

    }
}