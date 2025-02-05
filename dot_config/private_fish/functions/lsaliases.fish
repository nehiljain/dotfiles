function lsaliases --description "List all defined aliases in a clean format"
    # Get all aliases using alias command
    set -l all_aliases (alias)
    
    # Print header
    echo -e "\n📋 Aliases List\n"
    printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Process and print each alias
    for line in $all_aliases
        # Extract alias name and command, removing 'alias' prefix
        set -l parts (string replace -r '^alias\s+(\S+)\s+\'(.+)\'$' '$1\n$2' -- $line)
        
        # Print formatted output with colors and arrow separator
        set_color brblue
        printf "%-15s" $parts[1]
        set_color normal
        printf " ⟹  "
        set_color yellow
        printf "%s\n" $parts[2]
        set_color normal
    end
    
    # Print footer
    printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo # Add newline at end
end 