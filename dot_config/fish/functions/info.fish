function info
    if test (count $argv) -lt 1
        echo "Usage: info PROGRAM"
        return 1
    end

    if ! type -q $argv[1]
        echo "Error: command not found"
        return 2
    end

    whereis $argv[1]
    $argv[1] --version || $argv[1] version || $argv[1] -version || $argv[1] -V || true
end
