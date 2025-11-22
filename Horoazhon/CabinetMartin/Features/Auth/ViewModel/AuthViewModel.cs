using Horoazhon.Domain.Models;
using Horoazhon.Services.Command;
using Horoazhon.Services.Pin;
using Horoazhon.Services.User;
using Horoazhon.Domain.Models;
using Horoazhon.Domain.Services.Smtp;
using Horoazhon.Services.Command;
using Horoazhon.Services.Pin;
using Isopoh.Cryptography.Argon2;
using Microsoft.UI.Xaml.Shapes;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.DirectoryServices.AccountManagement;
using System.Linq;
using System.Net;
using System.Runtime.CompilerServices;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Input;
using Windows.System;
using User = Horoazhon.Services.User.UserService;

namespace Horoazhon.Features.Auth.ViewModel
{
    /// <summary>
    /// Classe de gestion de l'authentification
    /// </summary>
    public class AuthViewModel : IAuthViewModel, INotifyPropertyChanged
    {
        /// <summary>
        /// attributs : login, mot de passe, code pin, état des champs éditables, message d'information, connexion courante, personne courante
        /// </summary>
        private string? _login = null;
        private string? _password = null;
        private string? _codePin = null;
        private bool? _isEditable = false;
        private string? _messageInfo = "Veuillez saisir le mot de passe et le login";
        private Connexion? _connexion;
        private Personne? _personne;




        /// <summary>
        /// Permet d'afficher des messages d'information à l'utilisateur
        /// </summary>
        public string? MessageInfo
        {
            get => _messageInfo;
            set { _messageInfo = value; OnPropertyChanged(); }
        }

        /// <summary>
        /// Permet de saisir le login
        /// </summary>
        public string? LoginSelected
        {
            get => _login;
            set { _login = value; OnPropertyChanged(); }
        }

        /// <summary>
        /// Permet de saisir le mot de passe
        /// </summary>
        public string? PasswordSelected
        {
            get => _password;
            set { _password = value; OnPropertyChanged(); }
        }

        /// <summary>
        /// Permet de saisir le code pin reçu par email
        /// </summary>
        public string? CodePinSelected
        {
            get => _codePin;
            set { _codePin = value; OnPropertyChanged(); }
        }

        /// <summary>
        /// Rend les champs code pin et les boutons se connecter, obtenir le code pin éditables ou non
        /// </summary>
        public bool? IsEditable
        {
            get => _isEditable;
            set { _isEditable = value; OnPropertyChanged(); }
        }


        /// <summary>
        /// Contexte de la base de données
        /// </summary>     
        CabinetContext dbContext = new CabinetContext();

        /// <summary>
        /// Liste des connexions
        /// </summary>
        List<Connexion> connexions;

        /// <summary>
        /// Constructeur
        /// </summary>
        public AuthViewModel()
        {
            connexions = dbContext.Connexions.ToList();

        }

        /// <summary>
        /// Interface de commande pour la connexion
        /// </summary>
        public ICommand CommandLogin => new RelayCommand(_ => ActionLogin());

        /// <summary>
        /// Modifie l'état d'authentification de l'utilisateur courant (User)
        /// </summary>
        public bool IsAuthenticated
        {
            set
            {
                User.IsAuthenticated = value;
            }
            get => User.IsAuthenticated;
        }

        /// <summary>
        /// Vérifie si le code pin est correct et met à jour la date de dernière connexion ainsi que le nom et le rôle de l'utilisateur courant (User)
        /// </summary>
        /// <returns>bool</returns>
        public bool VerifiedPin()
        {

            IsAuthenticated = CodePinSelected == _connexion?.Codepincon?.Trim();
            if (_connexion != null && _connexion.Datedernierecon != null)
            {
                User.UserName = $"{_personne?.Nompers?.Trim()} {_personne?.Prenompers?.Trim()}";
                User.UserRole = _personne?.Rolepers?.Trim() ?? "User";
                User.AUser = _personne;
                _connexion.Codepincon = null;
                _connexion.Datedernierecon = DateTime.Now;
                dbContext.Connexions?.Update(_connexion ?? new());
                dbContext.SaveChanges();

                //Trace de connexion
                Trace.TraceInformation($"{DateTime.Now} : {User.UserName} - {User.UserRole} : Connexion réussie");
            }

            return IsAuthenticated;
        }


        /// <summary>
        /// Vérifie si le login, le mot de passe sont corrects  et envoie un code pin par email
        /// </summary>
        public void ActionLogin()
        {
            _connexion = connexions.Where(c => c.Logincon!.Trim().Equals(LoginSelected) && c.Mdpcon!.Trim().Equals(PasswordSelected)).FirstOrDefault();

            if (_connexion != null)
            {
                string hash = Argon2.Hash(PasswordSelected);
                bool ok = Argon2.Verify(PasswordSelected, _connexion.Mdpcon);

                Regex validateGuidRegex = new Regex("^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$");
                Console.WriteLine(validateGuidRegex.IsMatch(PasswordSelected));

                _personne = dbContext?.Personnes?.Where(p => p.Idpers.Equals(_connexion.Idpers)).FirstOrDefault() ?? null;
                _connexion.Codepincon = PinService.CreatePin(_personne?.Emailpers ?? "");

                SmtpService.Instance?.Send(_personne?.Emailpers?.Trim() ?? "", _connexion.Codepincon ?? "");
                MessageInfo = "Utilisateur reconnu, code PIN envoyé par email.";
                dbContext!.Connexions?.Update(_connexion ?? new());
                dbContext.SaveChanges();
                IsEditable = true;
                //Trace de connexion
                Trace.TraceInformation($"{DateTime.Now} : {User.UserName} - {User.UserRole} : Code Pin envoyé ");
                //AD


                // Modifier le login manuellement
                string username = _connexion!.Logincon!;
                // 🔧 Paramètres Active Directory 
                string domain = "cabinetmartin.local";
                string ouPath = "OU=cabMartin,DC=cabinetmartin,DC=local"; // OU où se trouve le groupe

                // Crée un contexte ciblant l’unité d’organisation "cabMartin"
                using (var context = new PrincipalContext(ContextType.Domain, domain, ouPath))
                {
                    // on cherche l’utilisateur courant
                    UserPrincipal user = UserPrincipal.FindByIdentity(context, username);

                    GroupPrincipal groupMedecin = GroupPrincipal.FindByIdentity(context, "Medecin");
                    GroupPrincipal groupAdmin = GroupPrincipal.FindByIdentity(context, "Administrateurs");
                    GroupPrincipal groupSecret = GroupPrincipal.FindByIdentity(context, "Secretaire");
                    /* Déterminer le groupe de l'utilisateur*/



                }

            }
            else
            {
                //Trace de connexion
                Trace.TraceError($"{DateTime.Now} : {User.UserName} - {User.UserRole} : erreur de connexion {Dns.GetHostByName(Dns.GetHostName()).AddressList[0].ToString()}");

                MessageInfo = "Utilisateur non reconnu, veuillez réessayer.";
                IsEditable = false;
            }
        }


        /// <summary>
        /// Test si les champs login et password sont remplis
        /// </summary>
        /// <returns></returns>
        public bool CanLogin()
        {
            try { } catch { }

            return !string.IsNullOrEmpty(LoginSelected) && !string.IsNullOrEmpty(PasswordSelected);
        }

        /// <summary>
        /// implémentation de INotifyPropertyChanged
        /// </summary>
        public event PropertyChangedEventHandler? PropertyChanged;
        private void OnPropertyChanged([CallerMemberName] string? n = null)
            => PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(n));
    }
}
