namespace ConfigurationForm
{
    partial class ConfigForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.saveButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.iniDataBindingSource = new System.Windows.Forms.BindingSource(this.components);
            this.tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel();
            this.launchButton = new System.Windows.Forms.Button();
            this.openIniButton = new System.Windows.Forms.Button();
            this.openConfigButton = new System.Windows.Forms.Button();
            this.tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel();
            this.newKeybindingIniButton = new System.Windows.Forms.Button();
            this.keybindingDefaultButton = new System.Windows.Forms.Button();
            this.newProfileIniButton = new System.Windows.Forms.Button();
            this.profileDefaultButton = new System.Windows.Forms.Button();
            this.profilesComboBox = new System.Windows.Forms.ComboBox();
            this.setProfileButton = new System.Windows.Forms.Button();
            this.keybindingsComboBox = new System.Windows.Forms.ComboBox();
            this.setKeybindingButton = new System.Windows.Forms.Button();
            this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
            ((System.ComponentModel.ISupportInitialize)(this.iniDataBindingSource)).BeginInit();
            this.tableLayoutPanel1.SuspendLayout();
            this.tableLayoutPanel2.SuspendLayout();
            this.SuspendLayout();
            // 
            // saveButton
            // 
            this.saveButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.saveButton.Location = new System.Drawing.Point(3, 4);
            this.saveButton.Name = "saveButton";
            this.saveButton.Size = new System.Drawing.Size(75, 23);
            this.saveButton.TabIndex = 0;
            this.saveButton.Text = "Save";
            this.saveButton.UseVisualStyleBackColor = true;
            this.saveButton.Click += new System.EventHandler(this.saveButton_Click);
            // 
            // cancelButton
            // 
            this.cancelButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.cancelButton.Location = new System.Drawing.Point(481, 4);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(75, 23);
            this.cancelButton.TabIndex = 1;
            this.cancelButton.Text = "Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            this.cancelButton.Click += new System.EventHandler(this.cancelButton_Click);
            // 
            // tableLayoutPanel1
            // 
            this.tableLayoutPanel1.BackColor = System.Drawing.Color.Transparent;
            this.tableLayoutPanel1.ColumnCount = 5;
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.66611F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.66611F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.66278F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 16.66278F));
            this.tableLayoutPanel1.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 33.34223F));
            this.tableLayoutPanel1.Controls.Add(this.saveButton, 0, 0);
            this.tableLayoutPanel1.Controls.Add(this.cancelButton, 4, 0);
            this.tableLayoutPanel1.Controls.Add(this.launchButton, 1, 0);
            this.tableLayoutPanel1.Controls.Add(this.openIniButton, 2, 0);
            this.tableLayoutPanel1.Controls.Add(this.openConfigButton, 3, 0);
            this.tableLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.tableLayoutPanel1.Location = new System.Drawing.Point(0, 631);
            this.tableLayoutPanel1.Name = "tableLayoutPanel1";
            this.tableLayoutPanel1.RowCount = 1;
            this.tableLayoutPanel1.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel1.Size = new System.Drawing.Size(559, 30);
            this.tableLayoutPanel1.TabIndex = 2;
            // 
            // launchButton
            // 
            this.launchButton.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.launchButton.Location = new System.Drawing.Point(102, 4);
            this.launchButton.Name = "launchButton";
            this.launchButton.Size = new System.Drawing.Size(75, 23);
            this.launchButton.TabIndex = 4;
            this.launchButton.Text = "Launch";
            this.launchButton.UseVisualStyleBackColor = true;
            this.launchButton.Click += new System.EventHandler(this.launchButton_Click);
            // 
            // openIniButton
            // 
            this.openIniButton.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.openIniButton.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.openIniButton.Location = new System.Drawing.Point(195, 4);
            this.openIniButton.Name = "openIniButton";
            this.openIniButton.Size = new System.Drawing.Size(75, 23);
            this.openIniButton.TabIndex = 2;
            this.openIniButton.Text = "Open INI";
            this.openIniButton.UseVisualStyleBackColor = true;
            this.openIniButton.Click += new System.EventHandler(this.openIniButton_Click);
            // 
            // openConfigButton
            // 
            this.openConfigButton.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.openConfigButton.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.openConfigButton.Location = new System.Drawing.Point(288, 4);
            this.openConfigButton.Name = "openConfigButton";
            this.openConfigButton.Size = new System.Drawing.Size(75, 23);
            this.openConfigButton.TabIndex = 5;
            this.openConfigButton.Text = "Open Config";
            this.openConfigButton.UseVisualStyleBackColor = true;
            this.openConfigButton.Click += new System.EventHandler(this.OpenConfigButton_Click);
            // 
            // tableLayoutPanel2
            // 
            this.tableLayoutPanel2.ColumnCount = 4;
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 17.5F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 40F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 25F));
            this.tableLayoutPanel2.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 17.5F));
            this.tableLayoutPanel2.Controls.Add(this.newKeybindingIniButton, 0, 1);
            this.tableLayoutPanel2.Controls.Add(this.keybindingDefaultButton, 3, 1);
            this.tableLayoutPanel2.Controls.Add(this.newProfileIniButton, 0, 0);
            this.tableLayoutPanel2.Controls.Add(this.profileDefaultButton, 3, 0);
            this.tableLayoutPanel2.Controls.Add(this.profilesComboBox, 1, 0);
            this.tableLayoutPanel2.Controls.Add(this.setProfileButton, 2, 0);
            this.tableLayoutPanel2.Controls.Add(this.keybindingsComboBox, 1, 1);
            this.tableLayoutPanel2.Controls.Add(this.setKeybindingButton, 2, 1);
            this.tableLayoutPanel2.Dock = System.Windows.Forms.DockStyle.Top;
            this.tableLayoutPanel2.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel2.Name = "tableLayoutPanel2";
            this.tableLayoutPanel2.RowCount = 2;
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel2.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            this.tableLayoutPanel2.Size = new System.Drawing.Size(559, 65);
            this.tableLayoutPanel2.TabIndex = 3;
            // 
            // newKeybindingIniButton
            // 
            this.newKeybindingIniButton.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.newKeybindingIniButton.Location = new System.Drawing.Point(3, 37);
            this.newKeybindingIniButton.Name = "newKeybindingIniButton";
            this.newKeybindingIniButton.Size = new System.Drawing.Size(75, 23);
            this.newKeybindingIniButton.TabIndex = 6;
            this.newKeybindingIniButton.Text = "New INI";
            this.newKeybindingIniButton.UseVisualStyleBackColor = true;
            this.newKeybindingIniButton.Click += new System.EventHandler(this.NewIniButtonClick);
            // 
            // keybindingDefaultButton
            // 
            this.keybindingDefaultButton.Anchor = System.Windows.Forms.AnchorStyles.Right;
            this.keybindingDefaultButton.Location = new System.Drawing.Point(481, 37);
            this.keybindingDefaultButton.Name = "keybindingDefaultButton";
            this.keybindingDefaultButton.Size = new System.Drawing.Size(75, 23);
            this.keybindingDefaultButton.TabIndex = 7;
            this.keybindingDefaultButton.Text = "Default";
            this.keybindingDefaultButton.UseVisualStyleBackColor = true;
            this.keybindingDefaultButton.Click += new System.EventHandler(this.DefaultButtonClick);
            // 
            // newProfileIniButton
            // 
            this.newProfileIniButton.Location = new System.Drawing.Point(3, 3);
            this.newProfileIniButton.Name = "newProfileIniButton";
            this.newProfileIniButton.Size = new System.Drawing.Size(75, 23);
            this.newProfileIniButton.TabIndex = 0;
            this.newProfileIniButton.Text = "New INI";
            this.newProfileIniButton.UseVisualStyleBackColor = true;
            this.newProfileIniButton.Click += new System.EventHandler(this.NewIniButtonClick);
            // 
            // profileDefaultButton
            // 
            this.profileDefaultButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.profileDefaultButton.Location = new System.Drawing.Point(481, 3);
            this.profileDefaultButton.Name = "profileDefaultButton";
            this.profileDefaultButton.Size = new System.Drawing.Size(75, 23);
            this.profileDefaultButton.TabIndex = 1;
            this.profileDefaultButton.Text = "Default";
            this.profileDefaultButton.UseVisualStyleBackColor = true;
            this.profileDefaultButton.Click += new System.EventHandler(this.DefaultButtonClick);
            // 
            // profilesComboBox
            // 
            this.profilesComboBox.Dock = System.Windows.Forms.DockStyle.Top;
            this.profilesComboBox.FormattingEnabled = true;
            this.profilesComboBox.Location = new System.Drawing.Point(100, 3);
            this.profilesComboBox.Name = "profilesComboBox";
            this.profilesComboBox.Size = new System.Drawing.Size(217, 21);
            this.profilesComboBox.TabIndex = 2;
            this.profilesComboBox.Text = "(Select INI)";
            this.profilesComboBox.SelectedValueChanged += new System.EventHandler(this.SelectedValueChanged);
            // 
            // setProfileButton
            // 
            this.setProfileButton.AutoSize = true;
            this.setProfileButton.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.setProfileButton.Location = new System.Drawing.Point(323, 3);
            this.setProfileButton.Name = "setProfileButton";
            this.setProfileButton.Size = new System.Drawing.Size(65, 23);
            this.setProfileButton.TabIndex = 3;
            this.setProfileButton.Text = "Set Profile";
            this.setProfileButton.UseVisualStyleBackColor = true;
            this.setProfileButton.Click += new System.EventHandler(this.SetButtonClick);
            // 
            // keybindingsComboBox
            // 
            this.keybindingsComboBox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right)));
            this.keybindingsComboBox.FormattingEnabled = true;
            this.keybindingsComboBox.Location = new System.Drawing.Point(100, 38);
            this.keybindingsComboBox.Name = "keybindingsComboBox";
            this.keybindingsComboBox.Size = new System.Drawing.Size(217, 21);
            this.keybindingsComboBox.TabIndex = 4;
            this.keybindingsComboBox.Text = "(Select INI)";
            this.keybindingsComboBox.SelectedValueChanged += new System.EventHandler(this.SelectedValueChanged);
            // 
            // setKeybindingButton
            // 
            this.setKeybindingButton.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.setKeybindingButton.AutoSize = true;
            this.setKeybindingButton.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.setKeybindingButton.Location = new System.Drawing.Point(323, 37);
            this.setKeybindingButton.Name = "setKeybindingButton";
            this.setKeybindingButton.Size = new System.Drawing.Size(93, 23);
            this.setKeybindingButton.TabIndex = 5;
            this.setKeybindingButton.Text = "Set Keybindings";
            this.setKeybindingButton.UseVisualStyleBackColor = true;
            this.setKeybindingButton.Click += new System.EventHandler(this.SetButtonClick);
            // 
            // ConfigForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(559, 661);
            this.Controls.Add(this.tableLayoutPanel2);
            this.Controls.Add(this.tableLayoutPanel1);
            this.Name = "ConfigForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Script Configuration";
            ((System.ComponentModel.ISupportInitialize)(this.iniDataBindingSource)).EndInit();
            this.tableLayoutPanel1.ResumeLayout(false);
            this.tableLayoutPanel2.ResumeLayout(false);
            this.tableLayoutPanel2.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Button saveButton;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.BindingSource iniDataBindingSource;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel1;
        private System.Windows.Forms.Button openIniButton;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel2;
        private System.Windows.Forms.Button newProfileIniButton;
        private System.Windows.Forms.Button profileDefaultButton;
        private System.Windows.Forms.ComboBox profilesComboBox;
        private System.Windows.Forms.Button setProfileButton;
        private System.Windows.Forms.OpenFileDialog openFileDialog;
        private System.Windows.Forms.Button launchButton;
        private System.Windows.Forms.Button newKeybindingIniButton;
        private System.Windows.Forms.Button keybindingDefaultButton;
        private System.Windows.Forms.ComboBox keybindingsComboBox;
        private System.Windows.Forms.Button setKeybindingButton;
        private System.Windows.Forms.Button openConfigButton;
    }
}

