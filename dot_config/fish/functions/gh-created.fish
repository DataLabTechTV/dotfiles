function gh-created
  set user_repo (echo $argv[1] \
    | awk 'match($0, /https?:\/\/github\.com\/([^\/]+\/[^\/]+)/, m) { print m[1] }')

  curl -s https://api.github.com/repos/$user_repo \
    | awk 'match($0, /created_at.*([0-9]{4}-[0-9]{2}-[0-9]{2})/, m) { print m[1] }'
end
