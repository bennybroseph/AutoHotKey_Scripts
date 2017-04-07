namespace ConfigurationForm
{
    using System;
#if !DEBUG
    using System.Diagnostics;
    using System.IO;
#endif
    using System.Windows.Forms;

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

            var ahkPath = 
                Directory.GetCurrentDirectory() + "\\AutoHotkey\\Joystick to Keyboard Emulation.exe";
            Process.Start(ahkPath);
#endif
        }
    }
}
