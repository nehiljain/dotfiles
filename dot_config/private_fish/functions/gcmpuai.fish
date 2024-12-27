function gcmpuai
    # Step 1: Get the git diff of staged changes
    set git_diff (git diff --cached)

    echo "Getting git diff..."

    # Step 2: Get the recent commit logs
    set git_log (git log -n 10 --pretty=format:'%h %s\n')

    echo "Getting git log..."

    echo "Generating commit message..."
    # Step 3: Generate commit message using LLM with the specified template
    # In neovim if you want to new line bullets do `:%s/\s\+-\s/\r- /g`
    set commit_message (git diff --cached | llm -m 4o-mini -t generate_convention_commit -p git_log "$git_log")

    # Post-process the commit message using awk
    # Remove the triple backticks and replace hyphens with bullet points
    set commit_message (echo "$commit_message" | sed 's/```//g' | sed 's/- /\n- /g')

    # Step 4: Allow user to edit the commit message
    echo "Generated commit message:\n\n$commit_message\n\n"
    echo "Do you want to (a)ccept, (e)dit, or (c)ancel?"
    read -l user_choice

    switch $user_choice
        case 'a'
            # Accept the generated message
            git commit -m "$commit_message"
            git push -u origin (git_current_branch)
        case 'e'
            # Edit the message using a text editor
            set temp_file (mktemp)
            echo $commit_message > $temp_file
            # Open the editor and wait for it to close
            nvim $temp_file
            # After the editor closes, read the edited message
            set edited_message (cat $temp_file)
            rm $temp_file
            git commit -m "$edited_message"
            git push -u origin (git_current_branch)
        case 'c'
            # Cancel the operation
            echo "Commit canceled."
        case '*'
            echo "Invalid choice. Commit canceled."
    end
    
end