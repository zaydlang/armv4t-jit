module util.error;

import core.stdc.stdlib;

import std.stdio;

/++
 + Displays the error message and terminates the program
 +/

void LogError(string error_message) {
    stderr.writeln(error_message);
    exit(-1);
}