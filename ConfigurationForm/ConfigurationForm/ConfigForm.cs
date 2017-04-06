namespace ConfigurationForm
{
    using System;
    using System.Diagnostics;
    using System.Drawing;
    using System.Linq;
    using System.Windows.Forms;
    using System.IO;

    public partial class ConfigForm : Form
    {
        private string m_ChosenConfigPath;

        private TabControl m_TabControl;
        private Tuple<int, int> m_TabControlOffset = new Tuple<int, int>(18, 40);

        public ConfigForm()
        {
            InitializeComponent();

            CenterToScreen();

            ChooseIniPath();
            AddComponents();
        }

        private void ChooseIniPath()
        {
            var configDirectory = Directory.GetCurrentDirectory() + "\\Configurations";
            if (!Directory.Exists(configDirectory))
            {
                MessageBox.Show(
                    "The folder \"Configurations\" was not found in " + Directory.GetCurrentDirectory(),
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Close();
                return;
            }

            var filePaths = Directory.GetFiles(configDirectory);

            if (filePaths.Length > 1)
            {
                var newForm = new ChooseConfigForm(configDirectory);
                AddOwnedForm(newForm);
                newForm.ShowDialog();

                m_ChosenConfigPath = newForm.chosenFile;
            }
            else if (filePaths.Length == 1)
                m_ChosenConfigPath = filePaths.FirstOrDefault();
            else
            {
                MessageBox.Show(
                    "The folder:\n\n\"" + configDirectory + "\"\n\nhas no valid configuration files " +
                    "(files ending in \".ini\")",
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Close();
                return;
            }

            if (m_ChosenConfigPath == null || !File.Exists(m_ChosenConfigPath))
            {
                MessageBox.Show(
                    "The selected file \n\n\"" + m_ChosenConfigPath + "\"\n\n does not exist or is invalid",
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Close();
                return;
            }
        }

        private void AddComponents()
        {
            var data = IniParserHelper.ParseIni(m_ChosenConfigPath);

            m_TabControl =
                new TabControl
                {
                    Size =
                        new Size(
                            Size.Width - m_TabControlOffset.Item1,
                            Size.Height - m_TabControlOffset.Item2),
                };
            Controls.Add(m_TabControl);

            foreach (var keyData in data.Global)
                Debug.WriteLine(keyData.Value);

            foreach (var dataSection in data.Sections)
            {
                foreach (var comment in dataSection.Comments)
                    Debug.WriteLine(comment);

                Debug.WriteLine(dataSection.SectionName);
                m_TabControl.TabPages.Add(
                    new TabPage
                    {
                        Text = dataSection.SectionName,
                        AutoSize = true,
                        AutoScroll = true,
                    });
                m_TabControl.SelectedIndex = m_TabControl.TabCount - 1;

                foreach (var sectionKey in dataSection.Keys)
                {
                    foreach (var comment in sectionKey.Comments)
                    {
                        Debug.WriteLine(comment);
                        m_TabControl.SelectedTab.Controls.Add(
                            new Label
                            {
                                Text = comment,
                                Location = new Point(0, m_TabControl.SelectedTab.Controls.Count * 20),
                                AutoSize = true,
                            });
                    }

                    Debug.WriteLine(sectionKey.KeyName + " = " + sectionKey.Value);
                }
            }
        }

        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);

            if (m_TabControl != null)
                m_TabControl.Size =
                    new Size(
                        Size.Width - m_TabControlOffset.Item1,
                        Size.Height - m_TabControlOffset.Item2);
        }
        //private class ScrollableTabPage : TabPage
        //{
        //    public ScrollableControl scrollableControl { get; private set; }

        //    public ScrollableTabPage()
        //    {
        //        scrollableControl = new ScrollableControl { Size = Size };
        //        Controls.Add(scrollableControl);
        //    }
        //}
    }
}
