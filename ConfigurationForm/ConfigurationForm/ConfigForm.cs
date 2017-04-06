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
        private Size m_TabControlOffset = new Size(18, 75);
        private int m_ControlVerticalOffset = 20;

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
                            Size.Width - m_TabControlOffset.Width,
                            Size.Height - m_TabControlOffset.Height),
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
                        Dock = DockStyle.Fill,
                        Padding = new Padding(10, 10, 10, 10)
                    });
                m_TabControl.SelectedIndex = m_TabControl.TabCount - 1;
                var tableLayoutPanel =
                    new TableLayoutPanel
                    {
                        ColumnCount = 2,
                        Dock = DockStyle.Fill,
                        AutoScroll = true,
                        ColumnStyles =
                        {
                            new ColumnStyle(SizeType.Percent, 30),
                            new ColumnStyle(SizeType.Percent, 70),
                        },
                    };
                m_TabControl.SelectedTab.Controls.Add(tableLayoutPanel);

                foreach (var sectionKey in dataSection.Keys)
                {
                    string totalComment = string.Empty;
                    foreach (var comment in sectionKey.Comments)
                    {
                        Debug.WriteLine(comment);
                        totalComment += comment + "\n";
                    }
                    if (totalComment != string.Empty)
                    {
                        var commentLabel =
                            new Label
                            {
                                Text = totalComment,
                                Anchor = AnchorStyles.Left,
                                AutoSize = true,
                                ForeColor = Color.DarkGreen,
                            };
                        tableLayoutPanel.Controls.Add(commentLabel, 0, tableLayoutPanel.RowCount);
                        tableLayoutPanel.SetColumnSpan(commentLabel, 2);

                        tableLayoutPanel.RowCount++;
                        tableLayoutPanel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                    }

                    Debug.WriteLine(sectionKey.KeyName + " = " + sectionKey.Value);
                    tableLayoutPanel.Controls.Add(
                        new Label
                        {
                            Text = sectionKey.KeyName + " = ",
                            Anchor = AnchorStyles.Left,
                            AutoSize = true,
                            Padding = new Padding(0, 0, 0, 10),
                        }, 0, tableLayoutPanel.RowCount);
                    tableLayoutPanel.Controls.Add(
                        new TextBox
                        {
                            Text = sectionKey.Value,
                            Anchor = AnchorStyles.Left,
                            AutoSize = true,
                            Padding = new Padding(0, 0, 0, 10),
                        }, 1, tableLayoutPanel.RowCount);

                    tableLayoutPanel.RowCount++;
                    tableLayoutPanel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
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
