function gcmpu
	git commit -m $argv
	git push -u origin (git_current_branch)
end
