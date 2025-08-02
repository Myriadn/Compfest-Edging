-- helpers.lua
-- Collection of utility functions for common operations

local helpers = {}

-- Check if a value is nil or an empty string
function helpers.isNilOrEmpty(value)
    return value == nil or (type(value) == "string" and value == "")
end

-- Get the distance between two points
function helpers.getDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Clamp a value between min and max
function helpers.clamp(value, min, max)
    return math.max(min, math.min(value, max))
end

-- Linear interpolation between two values
function helpers.lerp(a, b, t)
    return a + (b - a) * t
end

-- Round a number to a specific decimal place
function helpers.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Check if a point is inside a rectangle
function helpers.pointInRect(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.width and
           y >= rect.y and y <= rect.y + rect.height
end

-- Check if two rectangles are overlapping
function helpers.rectsOverlap(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
end

-- Split a string based on a delimiter
function helpers.split(str, delimiter)
    local result = {}
    local pattern = "(.-)" .. delimiter .. "()"
    local lastPos = 1

    for part, pos in string.gmatch(str, pattern) do
        table.insert(result, part)
        lastPos = pos
    end

    table.insert(result, string.sub(str, lastPos))
    return result
end

-- Get a random element from a table
function helpers.getRandomElement(tbl)
    if #tbl == 0 then return nil end
    return tbl[math.random(#tbl)]
end

-- Shuffle a table
function helpers.shuffleTable(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- Deep copy a table
function helpers.deepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in pairs(original) do
            copy[helpers.deepCopy(key)] = helpers.deepCopy(value)
        end
        setmetatable(copy, helpers.deepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Convert HSL color to RGB
function helpers.hslToRgb(h, s, l)
    local r, g, b

    if s == 0 then
        r, g, b = l, l, l
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end

        local q
        if l < 0.5 then
            q = l * (1 + s)
        else
            q = l + s - l * s
        end
        local p = 2 * l - q

        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end

    return r, g, b
end

return helpers
