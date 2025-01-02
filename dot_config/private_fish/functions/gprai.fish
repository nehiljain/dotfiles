function gprai
    # Step 1: Get the current branch name
    set current_branch (git_current_branch)

    # Step 2: Get PR list for the current branch
    set pr_list_json (gh pr list --head $current_branch --json number,title)
    
    # Step 3: Count PRs and get PR number if exists
    set pr_count (echo $pr_list_json | jq length)

    if test $pr_count -eq 0
        echo "No PR found for branch '$current_branch'. Aborting..."
        return 1
    end

    if test $pr_count -gt 2
        echo "More than 2 PRs found for branch '$current_branch'. Aborting..."
        return 1
    end

    # Get the first PR number
    set pr_number (echo $pr_list_json | jq -r '.[0].number')

    # Step 4: Get commit messages from main branch to current branch
    set commit_messages (git log origin/main..$current_branch --pretty=format:'%h %s')

    echo "Getting commit history..."

    # Step 5: Generate PR description using LLM
    echo "Generating PR description..."
    set pr_description (git log origin/main..$current_branch --pretty=format:'%h %s' | llm -m 4o-mini -t generate_pr_description "$commit_messages")

    # Post-process the PR description and ensure proper newlines
    # Remove code blocks and process bullet points
    set processed_description (echo "$pr_description" | sed 's/```//g' | perl -pe 's/\\n/\n/g' | sed 's/- /\n- /g')
    
    # Display the description with proper formatting
    echo "Generated PR description:"
    echo
    echo "$processed_description"
    echo
    echo "Do you want to (a)ccept, (e)dit, or (c)ancel?"
    read -l user_choice

    switch $user_choice
        case 'a'
            # Accept the generated description
            echo "$processed_description" | gh pr edit $pr_number -F -
            echo "Updated PR #$pr_number description."
        case 'e'
            # Edit the description using a text editor
            set temp_file (mktemp)
            echo "$processed_description" > $temp_file
            # Open the editor and wait for it to close
            nvim $temp_file
            # After the editor closes, read the edited description and update PR
            gh pr edit $pr_number -F $temp_file
            echo "Final description:"
            cat $temp_file
            rm $temp_file
            echo "Updated PR #$pr_number with edited description."

        case 'c'
            # Cancel the operation
            echo "Operation canceled."
        case '*'
            echo "Invalid choice. Operation canceled."
    end
end