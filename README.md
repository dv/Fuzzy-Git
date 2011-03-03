Fuzzy Git
=========

These are a series of scripts that extend common git commands with fuzzy finder functionality. For now, only `git-fuzzyadd` exists.

Installation
============

Create a symbolic link `/usr/bin/git-fuzzyadd` pointing to `git-fuzzyadd.rb`, e.g.:

    $ sudo ln -s ~/fuzzygit/git-fuzzyadd.rb /usr/bin/git-fuzzyadd 

Make sure the script is executable:

    $ sudo chmod a+x ~/fuzzygit/git-fuzzyadd.rb

To create a shorter alias for git-fuzzyadd, edit `~/.gitconfig`:

    ...
    
    [alias]
        ...
        fa = fuzzyadd
    
    ...

This will allow you to do as follows:

    $ git fa <pattern>


git-fuzzyadd
------------

Usage:

    $ git fuzzyadd <pattern>

A fuzzy git-add. Use it to add changed but not updated files that are already tracked. Fuzzy-Git uses staged fuzzy matching. It'll try to find files in decreasing order of specificity. It'll first try to match the pattern whole. If there are any slashes inside the given pattern, it'll try and match the directories, each as a whole word next. After that wildcards are added around the extension if any. If still nothing matches, any file which contains the characters in `pattern` in the same order, matches, even if there are other characters in between. If a given pattern matches multiple files, it will exit without doing anything.

git-fuzzyadd accepts multiple parameters and will consider each as an independent pattern to search for. 

Example:

    david@Seven:~/example$ git status
    # On branch master
    # Changed but not updated:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    # modified:   app/controller/posts_controller.rb
    # modified:   app/controller/user_controller.rb
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    # app/controller/comments_controller.rb
    # app/model/posts.rb
    no changes added to commit (use "git add" and/or "git commit -a")

Notice that there are two tracked files that are changed but not yet updated, and also two untracked files.

We'll try to add `posts_controller.rb`:

    david@Seven:~/example$ git fuzzyadd controller
    controller matches 2 files, please specify:
            app/controller/posts_controller.rb
            app/controller/user_controller.rb
    nothing happened.

`controller` also matches `app/controller/user_controller.rb`, so we need to be more specific because for security reasons fuzzyadd will only work when precisely one file matches:

    david@Seven:~/example$ git fuzzyadd post
    added app/controller/posts_controller.rb

Let's look at the status now:

    david@Seven:~example$ git status
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #	modified:   app/controller/posts_controller.rb
    #
    # Changed but not updated:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    #	modified:   app/controller/user_controller.rb
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #	app/controller/comments_controller.rb
    #	app/model/posts.rb

This is what we intuitivily expect to happen. If we try the exact same command again, we get a strange result:

    david@Seven:~/example$ git fuzzyadd post
    added app/controller/user_controller.rb.

Strange, but if you check, `post` indeed matches the file: *a**p**p/c**o**ntroller/u**s**er_con**t**roller.rb*. Why didn't it match this file the previous time? Because to Fuzzy-Git it was obvious that we meant posts_controller.rb and not some esoteric matching in user_controller.rb.
