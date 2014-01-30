function liquidApi.send(amount)
    amount = amount or 999999
    for liquidId, max in pairs(storage.liquids) do
        local amt = math.min(amount, max)
        local send = transferApi.send({{liquidId, amt}})
        if send then
            if send[1] then
                amt = amt - send[1][2]
            end
            if not liquidApi.use(liquidId, amt) then
                storage.liquids[liquidId] = nil
            end
            return true
        end
    end
    return false
end

function transferApi.receive(args)
    for _, liquid in ipairs(args.objects) do
        local give = liquidApi.give(liquid[1], liquid[2])
        if give then
            if give > 0 then
                return { { liquid[1], give } }
            end
            return {}
        end
    end
    return false
end

function transferApi.answer(liquids)
    for _, liquid in ipairs(liquids.objects) do
        local take = liquidApi.answer(liquid)
        if take then
            return { take }
        end
    end
    return false
end