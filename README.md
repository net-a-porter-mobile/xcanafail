# xcanafail

This gem is designed to be a very simple (and clumsy) way to work around the [-failOnWarnings bug in xctool](https://github.com/facebook/xctool/issues/436). When they fix that issue then this gem should be totally removed!

It's usage is very simple:

    > set -o pipefail 
    > xctool -workspace MyApp.workspace -scheme MyApp -reporter plain analyse | xcanafail -o output.txt | <some other utility> ...

It will pipe (untouched) the input from the preceding pipe through to stdout so it can be placed into a chain of utilities without having detremental effect. All it does is set it's exit code to 1 if it finds any analytics warnings in the output of xctool.

# How?

This is the gross bit. It's designed to be a quick hack to get our CI machine working so it's been written, erm, pragmatically. It uses regular expressions to detect when there is a warning, dumps the offending file(s) into the file specified by the `-o` parameter and sets it's exit code to 1. Otherwise it's exit code is 0.

# Removing it

When the bug in xctool is fixed, using `set -o pipefail` will mean that the any non-zero exit code from xctool will override the exit(0) from xcanafail so scripts with this included should seamlessly keep working. When you're confident that xctool is doing what you expect, take it out your script, uninstall the gem and forget it ever existed :)
