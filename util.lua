do
    local oldType = type
    function type(arg)
        return oldType(arg) == 'table' and arg.__type or oldType(arg)
    end
end