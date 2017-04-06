namespace ConfigurationForm
{
    using IniParser;
    using IniParser.Model;
    using IniParser.Model.Configuration;
    using IniParser.Parser;

    public static class IniParserHelper
    {
        public static IniData ParseIni(string iniPath)
        {
            var parser = new FileIniDataParser { Parser = { Configuration = { CommentString = ";" } } };
            var data = parser.ReadFile(iniPath);

            return data;
        }
    }
}
