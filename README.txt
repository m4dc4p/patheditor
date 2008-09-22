= PathEditor

Anyone who's had to change their Windows PATH environment variable more than once in a week knows it's a frustrating and error prone process.

This command line utility intends to fix that. It allows you to view, add, or remove paths from the PATH variable. It will also clean the variable of directorries that no longer exist. It's even smart enough to expand system variables such as %SystemRoot% when cleaning the path.

When the path is modified, all system processes are notified immediately. Not all programs will respond to the notification, but the current shell and future shells opened from the Start | Run box will. 

= Usage

For help, just type

  path_editor --help
  
To list the current path settings, just run the program without any arguments:

  path_editor

== Adding a Path

To add a directory to the path:

  path_editor --add "full path" --no-test

Note, because of the way the Windows shell works, if you wish to add a path with a trailing slash, you must use a double slash at the end:

  path_editor --add "c:\program files\\" --no-test
  
If the path already given already exists, it will not be added again.

== Removing a path

To remove a directory from the path:

  path_editor --remove "full path"
  
Limited regular expressions can be used - essentially "*" or "?", like filename wild cards. If more than one path matches the expression given, you will be asked for confirmation before the path variable is updated.

== Cleaning the Path

To clean your path:

  path_editor --clean
  
This process will remove directories which no longer exist, and will remove any duplicate directories from the path. 

= Acknowledgements

Of course, my thanks to Matz for creating Ruby. What a joy it is to program in. I'm also indebted to the fine coders of the "commandline" and "highline" libraries. Finally, my thanks to the King of Kings, Jesus Christ, for the gift of this life. Amen.

= LICENSE:

(The MIT License)

Copyright (c) 2007 Justin Bailey

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
