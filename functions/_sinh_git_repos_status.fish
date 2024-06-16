# Define a function that checks all folders set in sinh_git_folders and lists all git repos having changes within those folders.
function _sinh_git_repos_status --description "Check all folder set in sinh_git_folders and list all git repos having changes within those folders."

    # Define a helper function that checks a single git repository for changes.
    function sinh_gstatus
        # The path of the git repository is passed as an argument.
        set path $argv[1]

        # Check if the path exists and is a directory.
        if not test -d $path
            # If not, return immediately.
            return
        end

        # Check if the path is a git repository.
        if git -C $path rev-parse --git-dir >/dev/null 2>&1
            # Count the number of uncommitted changes.
            set count (git -C $path status --porcelain | wc -l)

            # Get the number of commits that are in the local branch but not in the upstream branch.
            set unpushed (git -C $path rev-list --count --left-right @{upstream}..HEAD 2>/dev/null)

            # Split the output of the previous command into two variables.
            set unpushed_local (echo $unpushed | awk '{print $2}')
            set unpushed_upstream (echo $unpushed | awk '{print $1}')

            # If there are uncommitted changes or unpushed commits, print the path and the counts.
            if test "$count" -gt 0 -o "$unpushed_local" -gt 0 -o "$unpushed_upstream" -gt 0
                echo $path "|" $count "|" $unpushed_local "|" $unpushed_upstream
            end
        else
            # If the path is not a git repository, check all its subdirectories.
            find $path -maxdepth 1 -mindepth 1 -type d | while read sub
                sinh_gstatus $sub
            end
        end
    end

    # Check if the sinh_git_folders variable is set.
    if not set --query sinh_git_folders
        # If not, print a message asking the user to set it.
        echo 'Please set sinh_git_folders variable in you config.fish with list of folders to check'
    else
        # If sinh_git_folders is set, check all the folders it contains.
        set repos_changed "Path | Uncommitted Changes | Local Commits | Upstream Commits"
        for i in $sinh_git_folders
            set repos_changed $repos_changed (sinh_gstatus $i)
        end
        # Print all the repositories with changes.
        for repo in $repos_changed
            echo $repo
        end
    end
end
