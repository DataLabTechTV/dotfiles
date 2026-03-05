function ls
    set args

    for arg in $argv
        if string match -rq '^-[^-]{2,}' -- $arg
            set compound_flags (string sub -s 2 -- $arg | string split '')

            for char in $compound_flags
                switch $char
                    case t
                        set args $args -s oldest
                    case '*'
                        set args $args -$char
                end
            end
        else if test $arg = -t
            set args $args -s oldest
        else
            set args $args $arg
        end
    end

    eza --icons --group-directories-first --binary --group $args
end
