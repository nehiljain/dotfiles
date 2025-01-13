function gcmpuai
    # Check for pre-commit hooks based on project type
    set precommit_files (find . -maxdepth 1 -type f -regex ".*\(pre-commit.*\.ya?ml\|\.pre-commit.*\.ya?ml\)")
    if test -n "$precommit_files"
        echo "Running pre-commit hooks..."
        set precommit_status (git diff --name-only --cached | xargs pre-commit run --files)
        if test $status -ne 0
            echo "Pre-commit checks failed. Please fix the issues and try again."
            return 1
        end
    else if test -f "package.json"
        # Read package.json to check for husky configuration
        set has_husky (cat package.json | string match -r '"husky":|"lint-staged":')
        if test -n "$has_husky"
            # Check for different package managers
            if test -f "pnpm-lock.yaml"
                echo "Running Node.js pre-commit hooks with pnpm..."
                if pnpm run | string match -q "*lint-staged*"
                    pnpm lint-staged
                else if pnpm run | string match -q "*precommit*"
                    pnpm run precommit
                else
                    pnpm exec lint-staged
                end
            else if test -f "package-lock.json"
                echo "Running Node.js pre-commit hooks with npm..."
                if npm run | string match -q "*lint-staged*"
                    npm run lint-staged
                else if npm run | string match -q "*lint*"
                    npm run lint
                else if npm run | string match -q "*precommit*"
                    npm run precommit
                end
            else if test -f "yarn.lock"
                echo "Running Node.js pre-commit hooks with yarn..."
                if yarn run | string match -q "*lint-staged*"
                    yarn lint-staged
                else if yarn run | string match -q "*precommit*"
                    yarn run precommit
                end
            end
            
            if test $status -ne 0
                echo "Pre-commit checks failed. Please fix the issues and try again."
                return 1
            end
        end
    end

    # Step 1: Get the git diff of staged changes
    set git_diff (git diff --cached)

    echo "Getting git diff..."

    # Step 2: Get the recent commit logs
    set git_log (git log -n 10 --pretty=format:'%h %s\n')

    echo "Getting git log..."

    echo "Generating commit message..."
    # Step 3: Generate commit message using LLM with the specified template
    # In neovim if you want to new line bullets do `%s/\s\+-\s/\r- /g`
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
            git commit -m "$commit_message" --no-verify
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
            git commit -m "$edited_message" --no-verify
            git push -u origin (git_current_branch)
        case 'c'
            # Cancel the operation
            echo "Commit canceled."
        case '*'
            echo "Invalid choice. Commit canceled."
    end
    
end