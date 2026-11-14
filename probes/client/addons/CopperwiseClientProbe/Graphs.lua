local _, Probe = ...

-- Five deliberately aligned synthetic observations, not production statistics.
function Probe.DrawGraphs(parent, samples, observedAt)
    local width, height = 500, 100
    local plots = {}
    local function text(owner, value, x, y, template)
        local label = owner:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", owner, "TOPLEFT", x, y)
        label:SetText(value)
        return label
    end
    local function line(plot, x1, y1, x2, y2, red, green, blue, thickness)
        local segment = plot:CreateLine(nil, "OVERLAY")
        segment:SetColorTexture(red, green, blue, 1)
        segment:SetThickness(thickness or 1)
        segment:SetStartPoint("BOTTOMLEFT", plot, x1, y1)
        segment:SetEndPoint("BOTTOMLEFT", plot, x2, y2)
    end
    for index, description in ipairs({
        {title = "SAMPLE asking price: copper/unit (white median; cyan spread bounds)", maximum = 400},
        {title = "SAMPLE supply: all listed units (amber)", maximum = 200},
    }) do
        local plot = CreateFrame("Frame", nil, parent)
        plots[index] = plot
        plot:SetSize(width, height)
        plot:SetPoint("TOPLEFT", parent, "TOPLEFT", 72, -150 - (index - 1) * 174)
        text(plot, description.title, 0, 25)
        text(plot, tostring(description.maximum), -42, 0)
        text(plot, "0", -16, -height + 12)
        if not plot.CreateLine then error("CreateLine unavailable") end
        for tick = 0, 4 do
            local x = tick * width / 4
            line(plot, x, 0, x, height, 0.2, 0.25, 0.3)
            local stamp = observedAt - (4 - tick) * 3600
            local label = text(plot, date("%H:%M", stamp), 0, -height - 7)
            label:ClearAllPoints()
            label:SetPoint("TOP", plot, "BOTTOMLEFT", x, -7)
        end
        line(plot, 0, 0, width, 0, 0.65, 0.65, 0.65)
        line(plot, 0, 0, 0, height, 0.65, 0.65, 0.65)
        for sampleIndex = 2, #samples do
            local x1, x2 = (sampleIndex - 2) * width / 4, (sampleIndex - 1) * width / 4
            local previous, current = samples[sampleIndex - 1], samples[sampleIndex]
            local scale = height / description.maximum
            if index == 1 then
                for _, field in ipairs({"lower", "upper"}) do
                    line(plot, x1, previous[field] * scale, x2, current[field] * scale, 0.2, 0.85, 0.95)
                end
                line(plot, x1, previous.median * scale, x2, current.median * scale, 1, 1, 1, 2)
            else
                line(plot, x1, previous.stock * scale, x2, current.stock * scale, 1, 0.7, 0.2, 2)
            end
        end
    end
    return plots
end
