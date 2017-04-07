using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ConfigurationForm
{
    using System.Diagnostics;
    using System.Runtime.InteropServices;

    internal static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            var newForm = new ConfigForm();
            if (!newForm.IsDisposed)
#if !DEBUG
                try
                {
#endif
                    Application.Run(newForm);
#if !DEBUG
                }
                catch (Exception e) { }
#endif
        }
    }
}
