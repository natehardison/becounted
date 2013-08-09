module StatsHelper

    def classIfZero(value)
        if value.to_int.zero?
            return "<span class='zero'>" + value.to_s + "</span>"
        else
            return value.to_s
        end
    end
    
end
