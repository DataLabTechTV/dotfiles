# Defined in - @ line 2
function gpa
	find ~/Git/ -maxdepth 2 -name ".git" -type d | sed -r 's|/[^/]+$||' | parallel --verbose git -C "{}" pull --all
end
