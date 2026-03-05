function pbcopy --wraps='wl-copy --type/text/plain' --wraps='wl-copy --type text/plain' --description 'alias pbcopy=wl-copy --type text/plain'
    wl-copy --type text/plain $argv
end
