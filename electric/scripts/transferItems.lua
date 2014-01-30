transferApi.minerals["item_placeholder"] = {
    dir = {
        false,
        { 1 },
        { 4 },
        false
    },
    config = function(item)
        if item[4].cat == "" then
            return true
        end
        return false
    end
}

function transferApi.configT(entityId, args, config)
    local left = {}
    for k, item in ipairs(args.objects) do
        for _, conf in ipairs(config) do
            if not conf(item) then

            end
        end
    end
end