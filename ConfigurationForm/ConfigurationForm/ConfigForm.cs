namespace ConfigurationForm
{
    using System;
    using System.Diagnostics;
    using System.Drawing;
    using System.Linq;
    using System.Windows.Forms;
    using System.IO;

    using BrightIdeasSoftware;

    using IniParser.Model;

    public partial class ConfigForm : Form
    {
        private string m_ChosenConfigPath;

        private TabControl m_TabControl;
        private Size m_TabControlOffset = new Size(18, 75);

        private IniData m_IniData;

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
            m_IniData = IniParserHelper.ParseIni(m_ChosenConfigPath);

            m_TabControl =
                new TabControl
                {
                    Size =
                        new Size(
                            Size.Width - m_TabControlOffset.Width,
                            Size.Height - m_TabControlOffset.Height),
                };
            Controls.Add(m_TabControl);

            foreach (var keyData in m_IniData.Global)
                Debug.WriteLine(keyData.Value);

            foreach (var dataSection in m_IniData.Sections)
            {
                foreach (var comment in dataSection.Comments)
                    Debug.WriteLine(comment);

                Debug.WriteLine(dataSection.SectionName);
                m_TabControl.TabPages.Add(
                    new TabPage
                    {
                        Text = dataSection.SectionName,
                        AutoScroll = true,
                        Dock = DockStyle.Fill,
                        Padding = new Padding(10, 10, 10, 10)
                    });
                m_TabControl.SelectedIndex = m_TabControl.TabCount - 1;
                m_TabControl.SelectedTab.Scroll += (sender, args) => Refresh();

                ObjectListView previousListView = null;
                foreach (var sectionKey in dataSection.Keys)
                {
                    string totalComment = string.Empty;
                    foreach (var comment in sectionKey.Comments)
                    {
                        Debug.WriteLine(comment);
                        totalComment += comment + "\n";
                    }
                    Label previousCommentLabel = null;
                    if (totalComment != string.Empty)
                        previousCommentLabel =
                            new Label
                            {
                                Text = totalComment,
                                ForeColor = Color.DarkGreen,
                            };

                    if (previousListView == null || previousCommentLabel != null)
                    {
                        previousListView =
                            new ObjectListView
                            {
                                Dock = DockStyle.Top,
                                HeaderStyle = ColumnHeaderStyle.Clickable,
                                Columns =
                                {
                                    new OLVColumn
                                    {
                                        Text = "Variable",
                                        AspectName = "KeyName",
                                        Width = 200,
                                        IsEditable = false,
                                    },
                                    new OLVColumn
                                    {
                                        Text = "Value",
                                        AspectName = "Value",
                                        Width = 100,
                                        IsEditable = true,
                                    },
                                },
                                CellEditActivation = ObjectListView.CellEditActivateMode.DoubleClick,
                                Margin = new Padding(0, 100, 0, 0),
                                ShowGroups = false,
                            };
                        m_TabControl.SelectedTab.Controls.Add(previousListView);
                    }

                    Debug.WriteLine(sectionKey.KeyName + " = " + sectionKey.Value);
                    previousListView.AddObject(sectionKey);
                }
            }
        }

        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);

            if (m_TabControl == null)
                return;

            m_TabControl.Width = Size.Width - m_TabControlOffset.Width;
            m_TabControl.Height = Size.Height - m_TabControlOffset.Height;

            Refresh();
        }

        protected override void OnClosed(EventArgs eventArgs)
        {
            base.OnClosed(eventArgs);

            foreach (var keyData in m_IniData.Global)
                Debug.WriteLine(keyData.Value);

            foreach (var dataSection in m_IniData.Sections)
            {
                foreach (var comment in dataSection.Comments)
                    Debug.WriteLine(comment);

                Debug.WriteLine(dataSection.SectionName);
                foreach (var sectionKey in dataSection.Keys)
                {
                    foreach (var comment in sectionKey.Comments)
                        Debug.WriteLine(comment);

                    Debug.WriteLine(sectionKey.KeyName + " = " + sectionKey.Value);
                }
            }
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
