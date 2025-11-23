using Castle.Core.Configuration;
using Microsoft.Extensions.Configuration;
using MimeKit;
using Microsoft.Extensions.Configuration.Json;
using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace Horoazhon.Domain.Services.Smtp
{
    public class SmtpService
    {
        private readonly Microsoft.Extensions.Configuration.IConfiguration configuration;
        private readonly string? _compte;
        private readonly string? _cleSecrete;
        static SmtpService? _instance;

        public static SmtpService Instance
        {
            get
            {
                return _instance ?? new();
            }
        }

        private SmtpService()
        {
            var builder = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json", optional: true)
                    .AddUserSecrets<MainWindow>();
            configuration = builder.Build();
            _compte = configuration["Authentification:Google:Email"];
            _cleSecrete = configuration["Authentification:Google:CleSecrete"];
        }
        public async Task<bool> Send(string email, string? pin=null)
        {
            if (email != null && email.Contains("@") && email.Contains("."))
            {
                try
                {
                    Trace.WriteLine($"Envoi du mail à {email} en cours...");
                    //var pin = PinService.CreatePin(email);
                    pin = "123456";
                    var message = new MimeMessage();
                    message.From.Add(new MailboxAddress("Horoazhon", _compte));
                    message.To.Add(new MailboxAddress("To", email));
                    message.Subject = "Votre code Pin";
                    message.Body = new TextPart("plain") { Text = $"Veuillez saisir votre code pin :\n          {pin}" };
                    using var client = new MailKit.Net.Smtp.SmtpClient();
                    await client.ConnectAsync("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
                    await client.AuthenticateAsync(_compte, _cleSecrete);
                    await client.SendAsync(message);
                    await client.DisconnectAsync(true);
                }
                catch (Exception ex)
                {
                    Trace.WriteLine($"Probleme lors de l'envoi...:{ex.Message}");
                }
                Trace.WriteLine($"Code pin envoyé à ... {email}...");
                return true;

            }
            return false;
        }
    }
}
