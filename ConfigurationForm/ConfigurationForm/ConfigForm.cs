namespace ConfigurationForm
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Diagnostics;
    using System.Drawing;
    using System.Linq;
    using System.Windows.Forms;
    using System.IO;
    using System.Text.RegularExpressions;

    using BrightIdeasSoftware;

    using IniParser.Model;

    public partial class ConfigForm : Form
    {
        private const string m_ConfigPath = "AutoHotkey\\config.ini";

        private string m_ChosenIniPath;

        private TabControl m_TabControl;
        private Point m_TabControlPoint = new Point(5, 30);
        private Size m_TabControlOffset = new Size(23, 110);

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
                var message =
                    "The folder \"Configurations\" was not found in " + Directory.GetCurrentDirectory();
                MessageBox.Show(
                    message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                throw new Exception(message);
            }

            var filePaths = Directory.GetFiles(configDirectory);

            if (filePaths.Length > 1)
            {
                var newForm = new ChooseConfigForm(configDirectory);
                AddOwnedForm(newForm);
                newForm.ShowDialog();

                m_ChosenIniPath = newForm.chosenFile;
            }
            else if (filePaths.Length == 1)
                m_ChosenIniPath = filePaths.FirstOrDefault();
            else
            {
                var message =
                    "The folder:\n\n\"" + configDirectory + "\"\n\nhas no valid configuration files " +
                    "(files ending in \".ini\")";
                MessageBox.Show(
                    message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                throw new Exception(message);
            }

            if (m_ChosenIniPath != null && !File.Exists(m_ChosenIniPath))
            {
                var message =
                    "The selected file \n\n\"" + m_ChosenIniPath + "\"\n\n does not exist or is invalid";
                MessageBox.Show(
                    message,
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                throw new Exception(message);
            }
        }

        private void AddComponents()
        {
            if (m_ChosenIniPath == null)
                return;

            SuspendLayout();

            m_IniData = IniParserHelper.ParseIni(m_ChosenIniPath);

            m_TabControl =
                new TabControl
                {
                    Location = m_TabControlPoint,
                    Size =
                        new Size(
                            Size.Width - m_TabControlOffset.Width,
                            Size.Height - m_TabControlOffset.Height),
                };
            Controls.Add(m_TabControl);

            foreach (var sectionData in m_IniData.Sections)
                m_TabControl.TabPages.Add(new MyTabPage(sectionData));

            ResumeLayout(true);
            Refresh();
        }

        private void SetInConfig()
        {
            var data = IniParserHelper.ParseIni(m_ConfigPath);
            foreach (var sectionData in data.Sections)
            {
                foreach (var sectionDataKey in sectionData.Keys)
                {
                    if (sectionDataKey.KeyName == "Preferences_Location")
                    {
                        var fileUri = new Uri(m_ChosenIniPath);
                        var referenceUri = new Uri(Directory.GetCurrentDirectory() + "\\AutoHotkey\\");

                        var relative =
                            "\\" + referenceUri.MakeRelativeUri(fileUri).ToString().Replace('/', '\\');
                        sectionDataKey.Value = relative;
                    }
                }
            }

            IniParserHelper.SaveIni(m_ConfigPath, data);
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

        protected override void OnClosing(CancelEventArgs e)
        {
            base.OnClosing(e);

            IniParserHelper.PrintIniData(m_IniData);

            var result =
                MessageBox.Show(
                    "Would you like to save first?",
                    "Quit",
                    MessageBoxButtons.YesNoCancel);

            if (result == DialogResult.Cancel)
                e.Cancel = true;

            if (result == DialogResult.Yes)
                IniParserHelper.SaveIni(m_ChosenIniPath, m_IniData);
        }

        private void saveButton_Click(object sender, EventArgs e)
        {
            var mouseEventArgs = e as MouseEventArgs;
            if (mouseEventArgs == null || mouseEventArgs.Button != MouseButtons.Left)
                return;

            var result =
                MessageBox.Show(
                    "Would you like to also set this .ini as the one used by the application?",
                    "Set in Config",
                    MessageBoxButtons.YesNo);

            if (result == DialogResult.Yes)
                SetInConfig();

            IniParserHelper.SaveIni(m_ChosenIniPath, m_IniData);
        }

        private void cancelButton_Click(object sender, EventArgs e)
        {
            var mouseEventArgs = e as MouseEventArgs;
            if (mouseEventArgs == null || mouseEventArgs.Button != MouseButtons.Left)
                return;

            var result =
                MessageBox.Show(
                    "Are you sure you want to exit? Unsaved changes will be lost!",
                    "Cancel",
                    MessageBoxButtons.YesNo);

            if (result == DialogResult.Yes)
                Application.Exit();
        }

        private void openIniButton_Click(object sender, EventArgs e)
        {
            var mouseEventArgs = e as MouseEventArgs;
            if (mouseEventArgs == null || mouseEventArgs.Button != MouseButtons.Left)
                return;

            Controls.Remove(m_TabControl);

            ChooseIniPath();
            AddComponents();
        }
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
        const string REGEX_URL =
        @"((http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?)";

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

                    var matches = Regex.Matches(totalComment, REGEX_URL);
                    if (matches.Count > 0)
                    {
                        var linkLabel = new LinkLabel
                        {
                            Text = totalComment,
                            Dock = DockStyle.Fill,
                            AutoSize = true,
                            ForeColor = Color.DarkGreen,
                        };
                        foreach (Match match in matches)
                            linkLabel.Links.Add(match.Index, match.Length, match.Value);

                        linkLabel.LinkClicked +=
                            (sender, args) => Process.Start(args.Link.LinkData.ToString());

                        previousCommentLabel = linkLabel;
                    }
                    else
                    {
                        previousCommentLabel =
                            new Label
                            {
                                Text = totalComment,
                                Dock = DockStyle.Fill,
                                AutoSize = true,
                                ForeColor = Color.DarkGreen,
                            };
                    }
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
                            BackColor = Color.WhiteSmoke,
                            UseAlternatingBackColors = true,
                            AlternateRowBackColor = Color.LightGray,
                            Columns =
                            {
                                new OLVColumn
                                {
                                    Text = "Variable",
                                    AspectName = "KeyName",
                                    HeaderForeColor = Color.DodgerBlue,
                                    Width = 200,
                                    FillsFreeSpace = true,
                                    IsEditable = false,
                                },
                                new OLVColumn
                                {
                                    Text = "Value",
                                    AspectName = "Value",
                                    HeaderForeColor = Color.DodgerBlue,
                                    Width = 250,
                                    IsEditable = true,
                                    AutoCompleteEditor = false,
                                },
                            },
                            CellEditActivation = ObjectListView.CellEditActivateMode.DoubleClick,
                            ShowGroups = false,
                        };

                    previousListView.CellEditStarting += HandleCellEditStarting;
                    previousListView.CellEditFinishing += HandleCellEditFinishing;

                    previousListView.MouseWheel +=
                        (sender, args) => (Parent as MyTabPage)?.OnMouseWheel(args);
                    totalListViews.Add(previousListView);
                    Controls.Add(previousListView, 0, RowCount - 1);
                }

                previousListView.AddObject(sectionKey);
            }

            foreach (var listView in totalListViews)
                listView.Height = 28 + listView.Items.Count * 17;
        }

        private void HandleCellEditStarting(object sender, CellEditEventArgs cellEditEventArgs)
        {
            var stringValue = cellEditEventArgs.Value as string;
            if (stringValue == null)
                return;

            if (bool.TryParse(stringValue, out var boolValue))
            {
                var boolCellEditor = new BooleanCellEditor
                {
                    Bounds = cellEditEventArgs.CellBounds,
                    ValueMember = boolValue.ToString(),
                };
                cellEditEventArgs.Control = boolCellEditor;
            }
            else if (float.TryParse(stringValue, out var floatValue))
            {
                var floatCellEditor = new FloatCellEditor
                {
                    Bounds = cellEditEventArgs.CellBounds,
                    Value = floatValue,
                };

                cellEditEventArgs.Control = floatCellEditor;
            }
            else
            {
                var newTextBox = new TextBox
                {
                    Bounds =
                        new Rectangle(
                            cellEditEventArgs.CellBounds.Location,
                            new Size(
                                cellEditEventArgs.CellBounds.Width,
                                cellEditEventArgs.CellBounds.Height)),
                    Text = cellEditEventArgs.Control.Text,
                };

                cellEditEventArgs.Control = newTextBox;
            }
        }
        private void HandleCellEditFinishing(object o, CellEditEventArgs cellEditEventArgs)
        {
            if (bool.TryParse(cellEditEventArgs.NewValue.ToString(), out var boolValue))
                cellEditEventArgs.NewValue = cellEditEventArgs.NewValue.ToString().ToLower();
            else
                cellEditEventArgs.NewValue = cellEditEventArgs.NewValue.ToString();
        }
    }
}
