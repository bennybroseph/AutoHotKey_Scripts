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
    using System.Runtime.InteropServices;

    using BrightIdeasSoftware;

    using IniParser.Model;

    public partial class ConfigForm : Form
    {
        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, Int32 wMsg, bool wParam, Int32 lParam);
        private const int WM_SETREDRAW = 11;

        private class IniTypeInfo
        {
            public string name;

            public string configKey;

            public string directoryPath;
            public string defaultPath;

            public ComboBox comboBox;

            public Button newButton;
            public Button setButton;
            public Button defaultButton;

            public string selectedIniPath;

            public IniTypeInfo(string newName)
            {
                name = newName;

                configKey = name + "_Path";

                directoryPath = sm_SettingsDirectory + name + "s\\";
                defaultPath = sm_DefaultsDirectory + name.ToLower() + ".ini";
            }
        }

        private const string SCRIPT_DIRECTORY = "AutoHotkey\\";
        private const string CONFIG_PATH = SCRIPT_DIRECTORY + "config.ini";
        private const string SCRIPT_PATH = SCRIPT_DIRECTORY + "Joystick to Keyboard Emulation.exe";

        private static readonly string sm_DefaultsDirectory =
            Directory.GetCurrentDirectory() + "\\Settings\\Defaults\\";

        private static readonly string sm_ConfigDefaultPath = sm_DefaultsDirectory + "config.ini";

        private static readonly string sm_SettingsDirectory = Directory.GetCurrentDirectory() + "\\Settings\\";

        private static readonly string sm_ScriptLocation = Directory.GetCurrentDirectory() + "\\AutoHotkey\\";

        private readonly List<IniTypeInfo> m_IniTypeInfo;

        private TabControl m_TabControl;
        private readonly Point m_TabControlPoint;
        private readonly Size m_TabControlOffset;

        private string m_SelectedIniPath;

        private IniData m_SelectedIniData;

        public ConfigForm()
        {
            InitializeComponent();

            m_IniTypeInfo = new List<IniTypeInfo>
            {
                new IniTypeInfo("Profile")
                {
                    comboBox = profilesComboBox,

                    newButton = newProfileIniButton,
                    setButton = setProfileButton,
                    defaultButton = profileDefaultButton,
                },
                new IniTypeInfo("Keybinding")
                {
                    comboBox = keybindingsComboBox,

                    newButton = newKeybindingIniButton,
                    setButton = setKeybindingButton,
                    defaultButton = keybindingDefaultButton,
                },
            };

            foreach (var iniTypeInfo in m_IniTypeInfo)
                PopulateComboBox(iniTypeInfo);

            openFileDialog.InitialDirectory = sm_SettingsDirectory;
            openFileDialog.Filter = @"INI Files|*.ini";

            m_TabControlPoint = new Point(5, tableLayoutPanel2.Size.Height);
            m_TabControlOffset = new Size(5, tableLayoutPanel2.Size.Height + tableLayoutPanel1.Size.Height);
        }

        private void PopulateComboBox(IniTypeInfo iniTypeInfo)
        {
            var iniFiles = GetAllFiles(iniTypeInfo);

            var fileDisplayNames =
                iniFiles.Select(
                        file => file.Substring(
                            file.IndexOf(iniTypeInfo.directoryPath, StringComparison.Ordinal)
                            + iniTypeInfo.directoryPath.Length)).
                    Cast<object>().ToArray();

            iniTypeInfo.comboBox.Items.Clear();
            iniTypeInfo.comboBox.Items.AddRange(fileDisplayNames);
        }

        private void RefreshComponents()
        {
            if (m_SelectedIniPath == null)
                return;

            var newToolTip = new ToolTip { UseFading = false };
            newToolTip.Show("Updating...", this, 0, 0);

            SendMessage(Handle, WM_SETREDRAW, false, 0);

            if (m_TabControl != null)
                Controls.Remove(m_TabControl);

            m_TabControl =
                new TabControl
                {
                    Location = m_TabControlPoint,
                    Size =
                        new Size(
                            ClientSize.Width - m_TabControlOffset.Width,
                            ClientSize.Height - m_TabControlOffset.Height),
                };
            Controls.Add(m_TabControl);

            foreach (var sectionData in m_SelectedIniData.Sections)
                m_TabControl.TabPages.Add(new MyTabPage(sectionData));

            m_TabControl.SelectedIndex = 0;

            SendMessage(Handle, WM_SETREDRAW, true, 0);

            newToolTip.Hide(this);
            Refresh();
        }

        private void SetInConfig(IniTypeInfo iniTypeInfo)
        {
            if (iniTypeInfo.selectedIniPath == null)
            {
                MessageBox.Show("No file selected", @"Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            var foundKey = false;

            var data = IniParserHelper.ParseIni(CONFIG_PATH);
            foreach (var sectionData in data.Sections)
            {
                if (foundKey)
                    break;

                foreach (var sectionDataKey in sectionData.Keys)
                {
                    if (sectionDataKey.KeyName != iniTypeInfo.configKey)
                        continue;

                    var relative = GetRelativePath(iniTypeInfo.selectedIniPath, sm_ScriptLocation);
                    sectionDataKey.Value = relative;
                    foundKey = true;

                    break;
                }
            }

            if (!foundKey)
            {
                MessageBox.Show(
                    "Couldn't find \"" + iniTypeInfo.configKey + "\" within " + CONFIG_PATH,
                    @"Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                return;
            }

            IniParserHelper.SaveIni(CONFIG_PATH, data);

            var newToolTip = new ToolTip();
            newToolTip.Show(iniTypeInfo.name + " Set", this, 5, 0, 3000);
        }

        protected override void OnResize(EventArgs e)
        {
            base.OnResize(e);

            if (m_TabControl == null)
                return;

            m_TabControl.Width = ClientSize.Width - m_TabControlOffset.Width;
            m_TabControl.Height = ClientSize.Height - m_TabControlOffset.Height;

            PerformLayout();
            Refresh();
        }

        protected override void OnClosing(CancelEventArgs e)
        {
            base.OnClosing(e);

            if (m_SelectedIniPath == null)
                return;

            IniParserHelper.PrintIniData(m_SelectedIniData);

            var result =
                MessageBox.Show(
                    "Would you like to save first?",
                    @"Quit",
                    MessageBoxButtons.YesNoCancel,
                    MessageBoxIcon.Question);

            if (result == DialogResult.Cancel)
                e.Cancel = true;

            if (result == DialogResult.Yes)
            {
                IniParserHelper.SaveIni(m_SelectedIniPath, m_SelectedIniData);
                MessageBox.Show(
                    GetRelativePath(m_SelectedIniPath, Directory.GetCurrentDirectory()) +
                    " has been saved!", "INI Saved");
            }
        }

        private void OpenIni(string newIniPath)
        {
            m_SelectedIniPath = newIniPath;
            if (m_SelectedIniPath != null && !File.Exists(m_SelectedIniPath))
            {
                var message =
                    "The selected file \n\n\"" + m_SelectedIniPath + "\"\n\n does not exist or is invalid";
                MessageBox.Show(
                    message,
                    @"Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                throw new Exception(message);
            }

            m_SelectedIniData = IniParserHelper.ParseIni(m_SelectedIniPath);
            RefreshComponents();

            Text = GetRelativePath(m_SelectedIniPath, Directory.GetCurrentDirectory());
        }

        private void OpenIni(IniTypeInfo iniTypeInfo)
        {
            OpenIni(iniTypeInfo.selectedIniPath);
            iniTypeInfo.comboBox.Text = GetRelativePath(iniTypeInfo.selectedIniPath, iniTypeInfo.directoryPath);
        }

        private void saveButton_Click(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            if (m_SelectedIniPath == null)
            {
                MessageBox.Show("No file selected", @"Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            IniParserHelper.SaveIni(m_SelectedIniPath, m_SelectedIniData);

            MessageBox.Show(
                GetRelativePath(m_SelectedIniPath, Directory.GetCurrentDirectory()) +
                " has been saved!", "INI Saved");
        }
        private void cancelButton_Click(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            if (m_SelectedIniPath == null)
                Application.Exit();

            var result =
                MessageBox.Show(
                    "Are you sure you want to exit? Unsaved changes will be lost!",
                    @"Cancel",
                    MessageBoxButtons.YesNo, MessageBoxIcon.Question);

            if (result == DialogResult.Yes)
                Application.Exit();
        }
        private void openIniButton_Click(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            var result = openFileDialog.ShowDialog();

            // In case the user moves/deletes files
            foreach (var iniTypeInfo in m_IniTypeInfo)
                PopulateComboBox(iniTypeInfo);

            if (result == DialogResult.OK)
                OpenIni(openFileDialog.FileName);
        }

        private void CreateNewIni(IniTypeInfo iniTypeInfo)
        {
            var inputDialogueForm = new InputDialogueForm("What will you name the new file?");
            inputDialogueForm.ShowDialog(this);

            if (inputDialogueForm.dialogResult != DialogResult.OK || inputDialogueForm.text == null)
                return;

            var newFilePath = iniTypeInfo.directoryPath + inputDialogueForm.text + ".ini";
            if (File.Exists(newFilePath))
            {
                MessageBox.Show(
                    @"A file with that name already exists!",
                    @"Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            File.Copy(iniTypeInfo.defaultPath, newFilePath);
            iniTypeInfo.selectedIniPath = newFilePath;

            PopulateComboBox(iniTypeInfo);
            OpenIni(iniTypeInfo);
        }
        private void NewIniButtonClick(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            var iniTypeInfo = m_IniTypeInfo.First(x => x.newButton == sender);
            CreateNewIni(iniTypeInfo);
        }
        private void DefaultButtonClick(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            var result =
                MessageBox.Show(
                    "This will overwrite ALL values in this file with the default ones.\n" +
                    "Are you SURE?",
                    @"Warning",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Warning);

            if (result != DialogResult.Yes)
                return;

            var iniTypeInfo = m_IniTypeInfo.First(x => x.defaultButton == sender);
            File.Copy(iniTypeInfo.defaultPath, iniTypeInfo.selectedIniPath, true);

            OpenIni(iniTypeInfo);
        }
        private void SetButtonClick(object sender, EventArgs e)
        {
            if (!(e is MouseEventArgs mouseEventArgs) || mouseEventArgs.Button != MouseButtons.Left)
                return;

            var iniTypeInfo = m_IniTypeInfo.First(x => x.setButton == sender);
            SetInConfig(iniTypeInfo);
        }
        private void launchButton_Click(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            Process.Start(SCRIPT_PATH);
        }

        private static IEnumerable<string> GetAllFiles(string path)
        {
            var files = new List<string>();
            try
            {
                files.AddRange(Directory.GetFiles(path));

                foreach (var dir in Directory.GetDirectories(path))
                    files.AddRange(GetAllFiles(dir));
            }
            catch (Exception exception)
            {
                MessageBox.Show(exception.Message);
            }

            return files;
        }

        string GetRelativePath(string filePath, string relativeLocation)
        {
            var pathUri = new Uri(filePath);
            // Folders must end in a slash
            if (!relativeLocation.EndsWith(Path.DirectorySeparatorChar.ToString()))
            {
                relativeLocation += Path.DirectorySeparatorChar;
            }
            var folderUri = new Uri(relativeLocation);
            return
                Uri.UnescapeDataString(
                    folderUri.MakeRelativeUri(pathUri).ToString().Replace('/', Path.DirectorySeparatorChar));
        }

        private void SelectedValueChanged(object sender, EventArgs e)
        {
            if (!(sender is ComboBox))
                return;

            var iniTypeInfo = m_IniTypeInfo.First(x => x.comboBox == sender);
            iniTypeInfo.selectedIniPath = iniTypeInfo.directoryPath + iniTypeInfo.comboBox.SelectedItem;

            OpenIni(iniTypeInfo.selectedIniPath);
        }

        private string[] GetAllFiles(IniTypeInfo iniTypeInfo)
        {
            if (!Directory.Exists(iniTypeInfo.directoryPath))
            {
                var message =
                    "The folder \"Profiles\" was not found in " + Directory.GetCurrentDirectory();
                MessageBox.Show(
                    message,
                    @"Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                throw new Exception(message);
            }

            var filePaths = GetAllFiles(iniTypeInfo.directoryPath).ToArray();
            if (!filePaths.Any())
            {
                var message =
                    "The folder:\n\n\"" + iniTypeInfo.directoryPath + "\"\n\nhas no valid configuration files " +
                    "(files ending in \".ini\")";
                MessageBox.Show(
                    message,
                    @"Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                throw new Exception(message);
            }

            var iniFiles = filePaths.Where(file => file.EndsWith(".ini")).ToArray();
            if (!iniFiles.Any())
            {
                var message = "There are no configuration files (files ending in \".ini\") in\n\n\"" +
                              sm_SettingsDirectory + "\"";
                MessageBox.Show(
                    message,
                    @"Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);

                Application.Exit();
                throw new Exception(message);
            }

            return iniFiles;
        }

        private void updateButton_Click(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            var updateCount = 0;
            foreach (var iniTypeInfo in m_IniTypeInfo)
            {
                var defaultIniData = IniParserHelper.ParseIni(iniTypeInfo.defaultPath);
                var defaultVersion = defaultIniData.Global.FirstOrDefault();
                foreach (var file in GetAllFiles(iniTypeInfo))
                {
                    var iniData = IniParserHelper.ParseIni(file);
                    var version = iniData.Global.FirstOrDefault();
                    if (defaultVersion == null
                        || version != null && float.Parse(defaultVersion.Value) < float.Parse(version.Value))
                    {
                        if (MessageBox.Show(
                                "The default INI version of \n'"
                                + GetRelativePath(file, Directory.GetCurrentDirectory())
                                + "' is lower than your saved settings.\n\n"
                                + "Did you forget to copy over the 'Defaults' folder from the new version?",
                                "Version Mis-Match",
                                MessageBoxButtons.OKCancel,
                                MessageBoxIcon.Error) == DialogResult.Cancel)
                            return;
                    }

                    switch (iniTypeInfo.name)
                    {
                        case "Keybinding":
                            if (version == null)
                            {
                                foreach (var sectionData in iniData.Sections)
                                    if (sectionData.SectionName == "Keybindings")
                                        sectionData.SectionName = "Controller";

                                iniData.Global.AddKey("Version", "4.1");

                                IniParserHelper.SaveIni(file, iniData);
                                iniData = IniParserHelper.ParseIni(file);

                                version = iniData.Global.FirstOrDefault();

                                ++updateCount;
                            }
                            break;

                        case "Profile":
                            if (version == null)
                            {
                                iniData.Global.AddKey("Version", "4.1");
                                version = iniData.Global.FirstOrDefault();

                                ++updateCount;
                            }
                            break;

                        default:
                            break;
                    }

                    // Copy present data over to the default settings and then save the modified defaults
                    // into the current INI file to maintain the key order from the default file.
                    foreach (var defaultSectionData in defaultIniData.Sections)
                    {
                        if (!iniData.Sections.ContainsSection(defaultSectionData.SectionName))
                            continue;

                        foreach (var defaultKeyData in defaultSectionData.Keys)
                        {
                            if (iniData.Sections
                                .GetSectionData(defaultSectionData.SectionName).Keys
                                .ContainsKey(defaultKeyData.KeyName))
                                defaultKeyData.Value =
                                    iniData.Sections
                                        .GetSectionData(defaultSectionData.SectionName).Keys
                                        .GetKeyData(defaultKeyData.KeyName).Value;
                        }
                    }

                    IniParserHelper.SaveIni(file, defaultIniData);
                }
            }

            // Update config to latest version
            {
                var defaultIniData = IniParserHelper.ParseIni(sm_ConfigDefaultPath);
                var defaultVersion = defaultIniData.Global.FirstOrDefault();

                var iniData = IniParserHelper.ParseIni(CONFIG_PATH);
                var version = iniData.Global.FirstOrDefault();

                if (defaultVersion == null
                    || version != null && float.Parse(defaultVersion.Value) < float.Parse(version.Value))
                {
                    if (MessageBox.Show(
                            "The default INI version of \n'"
                            + GetRelativePath(CONFIG_PATH, Directory.GetCurrentDirectory())
                            + "' is lower than your saved settings.\n\n"
                            + "Did you forget to copy over the 'Defaults' folder from the new version?",
                            "Version Mis-Match",
                            MessageBoxButtons.OKCancel,
                            MessageBoxIcon.Error) == DialogResult.Cancel)
                        return;
                }

                if (version == null)
                {
                    iniData.Global.AddKey("Version", "4.1");

                    IniParserHelper.SaveIni(CONFIG_PATH, iniData);
                    iniData = IniParserHelper.ParseIni(CONFIG_PATH);

                    version = iniData.Global.FirstOrDefault();

                    ++updateCount;
                }

                // Copy present data over to the default settings and then save the modified defaults
                // into the current INI file to maintain the key order from the default file.
                foreach (var defaultSectionData in defaultIniData.Sections)
                {
                    if (!iniData.Sections.ContainsSection(defaultSectionData.SectionName))
                        continue;

                    foreach (var defaultKeyData in defaultSectionData.Keys)
                    {
                        if (iniData.Sections
                            .GetSectionData(defaultSectionData.SectionName).Keys
                            .ContainsKey(defaultKeyData.KeyName))
                            defaultKeyData.Value =
                                iniData.Sections
                                    .GetSectionData(defaultSectionData.SectionName).Keys
                                    .GetKeyData(defaultKeyData.KeyName).Value;
                    }
                }

                IniParserHelper.SaveIni(CONFIG_PATH, defaultIniData);
            }

            if (updateCount > 0)
                MessageBox.Show("Updated " + updateCount + " file(s)!", "INIs updated");
            else
                MessageBox.Show(
                    "All INI files were already on the latest version. Missing keys and comments were added as needed.",
                    "INIs updated");
        }

        private void OpenConfigButton_Click(object sender, EventArgs e)
        {
            if (!IsLeftClick(e))
                return;

            OpenIni(Directory.GetCurrentDirectory() + "\\" + CONFIG_PATH);
        }

        private bool IsLeftClick(EventArgs e)
        {
            return e is MouseEventArgs mouseEventArgs && mouseEventArgs.Button == MouseButtons.Left;
        }
    }

    public class MyTabPage : TabPage
    {
        private readonly SectionData m_SectionData;

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
        // I didn't write this expression. These are awful, and I never have understood why there isn't a better way.
        const string REGEX_URL =
        @"((http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?)";

        private readonly SectionData m_SectionData;

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
                            HeaderStyle = ColumnHeaderStyle.Nonclickable,
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

        /// <summary>
        /// Called whenever a cell is edited. Assists in keeping the values of the same type they were read in as
        /// </summary>
        /// <param name="sender">The control which owns the edited cell</param>
        /// <param name="cellEditEventArgs">The event object</param>
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
