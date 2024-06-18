# Define a function that uses the output of _sinh_git_repos_status and pipes it to fzf for selection
function _sinh_fzf_git_repos_status --description "Take the output of _sinh_git_repos_status and pipe it to fzf"

    # Call _sinh_git_repos_status and store its output in selected_path
    set -f selected_path (
    # Loop over each line of the output
    for val in $(_sinh_git_repos_status)
      # Print the line
      echo "$val"
    end | 
    # Use awk to color the second column red if its value is greater than 0
    # Use awk to color the third column green if its value is greater than 0
    # Use awk to color the fourth column magenta if its value is greater than 0
    awk 'BEGIN {FS = "|"; OFS = "|"} $2 > 0 {$2 = "\033[31m" $2 "\033[0m"} $3 > 0 {$3 = "\033[32m" $3 "\033[0m"} $4 > 0 {$4 = "\033[35m" $4 "\033[0m"} 1' | 
    # Format the output as a table and pipe it to fzf for selection
    column -t -s '|' | fzf \
       --ansi --layout=reverse --height=80%  \
       --bind 'enter:become(echo {1})' \
       --header-lines=1 \
       --query=(commandline --current-token) \
       --preview 'git -C {1} status'
  )

    # If a selection was made in fzf
    if test $status -eq 0
        # Loop over each line of the selection
        for line in $selected_path
            # Split the line into fields and store the first field (the path) in the path variable
            set -f path $line
        end
        # Replace the current command line token with a cd command to the selected path
        commandline --current-token "$path"
    end
end
