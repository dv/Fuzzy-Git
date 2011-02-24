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

A fuzzy git-add. Use it to add changed but not updated files that are already tracked. Any file which contains the characters in `pattern` in the same order, matches, even if there are other characters in between. If a given pattern matches multiple files, it will exit without doing anything.

git-fuzzyadd accepts multiple parameters and will consider each as an independent pattern to search for. 

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
    post matches 2 files, please specify:
            app/controller/posts_controller.rb
            app/controller/user_controller.rb
    nothing happened.

If you manually check, `post` also matches both files: *a**p**p/c**o**ntroller/u**s**er_con**t**roller.rb*. If we use `posts` it matches only one file, so let's do that:

    david@Seven:/tmp/example$ git fuzzyadd posts
    added app/controller/posts_controller.rb.

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

Just what we wanted!

