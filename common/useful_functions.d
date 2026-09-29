
module useful_functions;



import std.stdio: writeln;
import std.process: executeShell;
import std.file: thisExePath, getcwd;
import std.path: dirName;

//void writeAndPause(string s = "")
void writeAndPause(string s)
{
    writeln(s);
    version(Windows)
    {  
        // pause command prints out
        // "Press any key to continue..."

        // auto ret = executeShell("pause");
        // if (ret.status == 0)
        //     writeln(ret.output);

        // The functions capture what the child process prints to both its standard output 
        // and standard error streams, and return this together with its exit code.
        // The problem is we don't have the pause return output until after the user
        // hits a key.

        //writeln();
        writeln("Press any key to continue...");       
        executeShell("pause");  // don't bother with standard output the child returns

    }
    else // Mac OS or Linux
    {
        writeln("Press any key to continue...");
        executeShell(`read -n1 -r`);    // -p option did not work
    }
    writeln();
}



/+ Note: even when I stated the executable away for its home, only the cwd reflected this. 
fullPathWithExecName =      C:\Users\Administrator\Documents\GitHub\Dfine\dfine.exe
fullPathWithoutExecName =   C:\Users\Administrator\Documents\GitHub\Dfine
current working directory = C:\Users\Administrator\Documents\GitHub\Dfine\notes
+/


string getFullPathToExecuableFile()
{
    string fullPathWithExecName;     // absolute path name to executive file with file name appended at end
    string fullPathWithoutExecName;  // absolute path to the executable file (without the file name)

    
    fullPathWithExecName = thisExePath(); // return the full path to the currently running executable

    writeln("fullPathWithExecName = ", fullPathWithExecName);
    
    fullPathWithoutExecName = dirName(fullPathWithExecName);  // returns the parent directory of executive
    
    writeln("fullPathWithoutExecName = ", fullPathWithoutExecName);
    writeln("current working directory = ", getcwd());
    
    return fullPathWithoutExecName;
}
