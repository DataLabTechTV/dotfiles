function gpw
    set -l repos homelab desak desak-dags configs

    for repo in $repos
        git -C ~/Git/$repo/ pull -v --all >/dev/null &
    end

    wait
end
