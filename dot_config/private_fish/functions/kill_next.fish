function kill_next
    echo "🔍 Searching for Next.js processes..."
    
    # Find processes running Next.js
    set next_processes (ps aux | grep -i 'next' | grep -v 'grep')

    # Check if any processes were found
    if test -z "$next_processes"
        echo "✅ No Next.js processes found."
        return 0
    end

    # Display found processes
    echo "🛑 Found Next.js processes:"
    echo "$next_processes"

    # Extract PIDs
    set pids (echo "$next_processes" | awk '{print $2}')

    # Kill processes
    for pid in $pids
        echo "💀 Killing process $pid..."
        kill -9 $pid
    end

    echo "✅ All Next.js processes have been killed."
end
