using System;
using System.IO;

//This is an Example C# Console Application
//its intent is to process each file 1 at a time.

namespace Win32ConsoleApplication
{
    class Program
    {

        private static void Main(string[] args)
        {
            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(OnUnhandledException);

            DisplayWarningIfUnexpectedNumberOfArguments(args);
            
            var fullPathToFile = GetArgumentSafe(args, 0);
            var server = GetArgumentSafe(args, 1);
            var languageShortName = GetArgumentSafe(args, 2);

            if (IsFilePathValid(fullPathToFile))
            {
                ProcessFile(fullPathToFile, server, languageShortName);
                Console.WriteLine("Completed Processing: {0}", fullPathToFile);
            }
            else
            {
                throw new Exception("Critical Error:  Nothing processed, path to csv file is invalid");
            }            
            
        }

        public static void OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            var exception = (Exception)e.ExceptionObject;

            //bail out in a tidy way and perform your logging
        }

        static private void ProcessFile(string fullPathToFile, string server, string languageShortName)
        {
       
            Console.WriteLine("Full Path To CSV File             - {0} \n" +
                              "Server                            - {1} \n" +
                              "Supported Language Short          - {2} \n\n" +
                              "Processing...... \n", fullPathToFile, server, languageShortName);

            //Put your processing code here.            
        }

        static private bool IsFilePathValid(string fullPathToFile)
        {
            return File.Exists(fullPathToFile);
        }

        static private void DisplayWarningIfUnexpectedNumberOfArguments(string[] args)
        {
            var argumentCount = 0;
            if (args == null)
            {
                DisplayConsoleWarning(argumentCount);   
            }else if (args.Length != 3)
            {
                argumentCount = args.Length;
                DisplayConsoleWarning(argumentCount);
                DisplayAllArguments(args);
            }
        }

        static private void DisplayConsoleWarning(int value)
        {
          Console.WriteLine("-------------------------------------------------------------------");
          Console.WriteLine("Warning: Expected Command Line Arguments is 3, found = {0} \n", value);
          Console.WriteLine("-------------------------------------------------------------------");
        }

        static private void DisplayAllArguments(string[] args)
        {
            foreach (string s in args)
            {
                Console.WriteLine(s);
            }
        }
        static private string GetArgumentSafe(string[] args, int index)
        {
            var argument = "";
            if (args != null && index < args.Length)
            {
                argument = args[index];
            }
            return argument;
        }      
    }
}
