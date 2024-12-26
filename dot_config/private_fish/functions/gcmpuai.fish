function gcmpuai
    # Step 1: Get the git diff of staged changes
    set git_diff (git diff --cached)

    # Step 2: Get the recent commit logs
    set git_log (git log -n 10 --pretty=format:'%h %s')

    # Step 3: Generate commit message using LLM with the specified template
    set commit_message (llm -t generate_convention_commit -p git_diff "$git_diff" -p git_log "$git_log")

    # Step 4: Allow user to edit the commit message
    echo "Generated commit message:\n$commit_message\n"
    echo "Do you want to (a)ccept, (e)dit, or (c)ancel?"
    read -l user_choice

    switch $user_choice
        case 'a'
            # Accept the generated message
            git commit -m "$commit_message"
        case 'e'
            # Edit the message using a text editor
            set temp_file (mktemp)
            echo $commit_message > $temp_file
            $EDITOR $temp_file
            set edited_message (cat $temp_file)
            rm $temp_file
            git commit -m "$edited_message"
        case 'c'
            # Cancel the operation
            echo "Commit canceled."
        case '*'
            echo "Invalid choice. Commit canceled."
    end
end