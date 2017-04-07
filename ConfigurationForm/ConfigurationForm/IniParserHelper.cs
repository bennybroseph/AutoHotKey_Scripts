namespace ConfigurationForm
{
    using System.Diagnostics;

    using IniParser;
    using IniParser.Model;

    public static class IniParserHelper
    {
        public static IniData ParseIni(string iniPath)
        {
            var parser = new FileIniDataParser { Parser = { Configuration = { CommentString = ";" } } };
            var data = parser.ReadFile(iniPath);

            return data;
        }

        public static void SaveIni(string iniPath, IniData iniData)
        {
            var parser = new FileIniDataParser{ Parser = { Configuration = { CommentString = ";" } } };
            parser.WriteFile(iniPath, iniData);
        }

        public static void PrintIniData(IniData iniData)
        {
            foreach (var keyData in iniData.Global)
                Debug.WriteLine(keyData.Value);

            foreach (var dataSection in iniData.Sections)
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
    }
}
