namespace ConfigurationForm
{
    using System;
    using System.Linq;
    using System.Windows.Forms;
    using System.IO;

    public partial class ChooseConfigForm : Form
    {
        private string m_CurrentDirectory;

        public string chosenFile { get; private set; }

        public ChooseConfigForm(string currentDirectory)
        {
            InitializeComponent();

            CenterToParent();

            m_CurrentDirectory = currentDirectory;

            var iniFiles =
                Directory.GetFiles(m_CurrentDirectory).Where(file => file.EndsWith(".ini")).ToArray();
            if (!iniFiles.Any())
            {
                MessageBox.Show(
                    "There are no configuration files (files ending in \".ini\") in\n\n\"" +
                    currentDirectory + "\"",
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Close();
                return;
            }

            var fileDisplayNames =
                iniFiles.Select(
                    file => file.Substring(
                        file.IndexOf(
                            m_CurrentDirectory, StringComparison.Ordinal) + m_CurrentDirectory.Length)).
                Cast<object>().ToArray();

            configComboBox.Items.AddRange(fileDisplayNames);
            configComboBox.SelectedIndex = 0;
        }

        private void OkButton_MouseClick(object sender, MouseEventArgs mouseEventArgs)
        {
            if (mouseEventArgs.Button != MouseButtons.Left)
                return;

            chosenFile = m_CurrentDirectory + configComboBox.SelectedItem;
            Close();
        }

        private void CancelButton_MouseClick(object sender, MouseEventArgs mouseEventArgs)
        {
            if (mouseEventArgs.Button != MouseButtons.Left)
                return;

            Close();
        }
    }
}
