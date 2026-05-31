# Tide prompt configuration — runs once on first fish launch.
# To reconfigure interactively: tide configure
# To change defaults: edit the command below and delete tide_prompt_icon_connection
# universal variable so this block re-runs: set -Ue tide_prompt_icon_connection

if not set -q tide_prompt_icon_connection
    tide configure --auto \
        --style=Lean \
        --prompt_colors='True color' \
        --show_time='24-hour format' \
        --lean_prompt_height='Two lines' \
        --prompt_connection=Dotted \
        --prompt_connection_andor_frame_color=Dark \
        --prompt_spacing=Sparse \
        --icons='Few icons' \
        --transient=No
end
