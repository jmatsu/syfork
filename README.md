# syfork
Easy to synchronize forked repository with super repository. (fetch only.)

# Installation

Add syfork to $PATH

# Usage

    syfork -h #=> show this help
    syfork --version #=> show this version
    syfork -r $(remote of your forked repository) $(path/to/repo)...
    syfork -s $(remote of super repository) $(path/to/repo)...
    syfork -r $(...) -s $(...) $(path/to/repo)...

# Example

    syfork -r origin -s super ../repo1 ~/repos/repo2 /Users/hoge/repos/repo3

# Test Environment

### Shell

    GNU bash, version 3.2.53(1)-release (x86_64-apple-darwin13)
    Copyright (C) 2007 Free Software Foundation, Inc.

    zsh 5.0.7 (x86_64-apple-darwin13.4.0)

### Git

    git version 2.4.1