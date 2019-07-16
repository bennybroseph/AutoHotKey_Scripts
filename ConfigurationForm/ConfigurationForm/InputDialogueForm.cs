namespace ConfigurationForm
{
    using System.Windows.Forms;

    public partial class InputDialogueForm : Form
    {
        public string text { get; private set; } = null;
        public DialogResult dialogResult { get; private set; } = DialogResult.Cancel;

        public InputDialogueForm(string dialogueText)
        {
            InitializeComponent();

            CenterToParent();

            dialogueLabel.Text = dialogueText;
        }

        private void SetText()
        {
            dialogResult = DialogResult.OK;
            text = textInputBox.Text.Replace(' ', '_');
        }
        private void OkButton_MouseClick(object sender, MouseEventArgs mouseEventArgs)
        {
            if (mouseEventArgs.Button != MouseButtons.Left)
                return;

            SetText();
            Close();
        }

        private void CancelButton_MouseClick(object sender, MouseEventArgs mouseEventArgs)
        {
            if (mouseEventArgs.Button != MouseButtons.Left)
                return;

            Close();
        }

        private void TextInputBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyData != Keys.Enter)
                return;

            SetText();
            Close();
        }
    }
}
