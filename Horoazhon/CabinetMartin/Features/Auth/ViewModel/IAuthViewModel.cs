using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Input;

namespace Horoazhon.Features.Auth.ViewModel
{
    public interface IAuthViewModel
    {
        public string? LoginSelected { get; set; }
        public string? CodePinSelected { get; set; }
        public string? PasswordSelected { get; set; }
        public string? MessageInfo { get; set; }
        public bool? IsEditable { get; set; }
        ICommand CommandLogin { get; }
        void ActionLogin();
        bool CanLogin();        

        bool IsAuthenticated { get; set; }        

    }
}
