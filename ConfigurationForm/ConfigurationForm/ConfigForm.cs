namespace ConfigurationForm
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Drawing;
    using System.Linq;
    using System.Windows.Forms;
    using System.IO;
    using System.Windows.Forms.VisualStyles;

    using BrightIdeasSoftware;

    using IniParser.Model;

    public partial class ConfigForm : Form
    {
        private string m_ChosenConfigPath;

        private TabControl m_TabControl;
        private Size m_TabControlOffset = new Size(23, 80);

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
                    Location = new Point(5, 5),
                    Size =
                        new Size(
                            Size.Width - m_TabControlOffset.Width,
                            Size.Height - m_TabControlOffset.Height),
                };
            Controls.Add(m_TabControl);

            foreach (var sectionData in m_IniData.Sections)
                m_TabControl.TabPages.Add(new MyTabPage(sectionData));
        }

        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);

            if (m_TabControl == null)
                return;

            m_TabControl.Width = Size.Width - m_TabControlOffset.Width;
            m_TabControl.Height = Size.Height - m_TabControlOffset.Height;

            PerformLayout();
            Refresh();
        }

        protected override void OnClosed(EventArgs eventArgs)
        {
            base.OnClosed(eventArgs);

            IniParserHelper.PrintIniData(m_IniData);
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

    public class MyTabPage : TabPage
    {
        private SectionData m_SectionData;

        public MyTabPage(SectionData sectionData)
        {
            m_SectionData = sectionData;

            Text = m_SectionData.SectionName;
            Dock = DockStyle.Fill;
            AutoScroll = true;
            Padding = new Padding(10, 10, 10, 10);

            Scroll += (sender, args) => Refresh();
        }

        protected override void InitLayout()
        {
            var tabControl = Parent as TabControl;
            if (tabControl == null)
            {
                Debug.WriteLine("WARNING: The custom component " + Text + " is not a child of a 'TabPage'!");
                return;
            }

            tabControl.SelectedIndex = tabControl.TabCount - 1;

            Controls.Add(new MyTableLayoutPanel(m_SectionData));
        }

        public new void OnMouseWheel(MouseEventArgs mouseEventArgs)
        {
            base.OnMouseWheel(mouseEventArgs);
        }
    }

    public class MyTableLayoutPanel : TableLayoutPanel
    {
        private SectionData m_SectionData;

        public MyTableLayoutPanel(SectionData sectionData)
        {
            m_SectionData = sectionData;

            Dock = DockStyle.Top;
            AutoSize = true;
            AutoSizeMode = AutoSizeMode.GrowAndShrink;
            TabIndex = 0;

            ColumnCount = 1;
            ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

            RowCount = 0;
            RowStyles.Clear();
        }

        protected override void InitLayout()
        {
            SuspendLayout();
            
            var totalListViews = new List<FastObjectListView>();

            FastObjectListView previousListView = null;
            foreach (var sectionKey in m_SectionData.Keys)
            {
                var totalComment = string.Empty;
                foreach (var comment in sectionKey.Comments)
                    totalComment += comment.Trim(' ', '\n') + "\n";

                Label previousCommentLabel = null;
                if (totalComment != string.Empty)
                {
                    RowCount++;

                    totalComment = totalComment.Trim(' ', '\n');
                    previousCommentLabel =
                        new Label
                        {
                            Text = totalComment,
                            Dock = DockStyle.Fill,
                            AutoSize = true,
                            ForeColor = Color.DarkGreen,
                        };
                    Controls.Add(previousCommentLabel, 0, RowCount - 1);
                }

                if (previousListView == null || previousCommentLabel != null)
                {
                    RowCount++;
                    
                    previousListView =
                        new FastObjectListView
                        {
                            HeaderStyle = ColumnHeaderStyle.Clickable,
                            Dock = DockStyle.Fill,
                            GridLines = true,
                            RowHeight = 0,
                            BackColor = Color.White,
                            AlternateRowBackColor = Color.Gray,
                            Columns =
                            {
                                new OLVColumn
                                {
                                    Text = "Variable",
                                    AspectName = "KeyName",
                                    Width = 200,
                                    FillsFreeSpace = true,
                                    IsEditable = false,
                                },
                                new OLVColumn
                                {
                                    Text = "Value",
                                    AspectName = "Value",
                                    Width = 250,
                                    IsEditable = true,
                                },
                            },
                            CellEditActivation = ObjectListView.CellEditActivateMode.DoubleClick,
                            ShowGroups = false,
                        };
                    previousListView.MouseWheel += 
                        (sender, args) => (Parent as MyTabPage)?.OnMouseWheel(args);
                    totalListViews.Add(previousListView);
                    Controls.Add(previousListView, 0, RowCount - 1);
                }

                previousListView.AddObject(sectionKey);
            }

            foreach (var listView in totalListViews)
                listView.Height = 28 + listView.Items.Count * 17;
            
            ResumeLayout(true);
        }
    }
}
