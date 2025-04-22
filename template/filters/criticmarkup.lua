-- CriticMarkup Lua Filter for Pandoc
-- Handles CriticMarkup annotations for HTML, LaTeX, and DOCX: {++add++}, {--delete--}, {~~substitute~>replacement~~}, {==highlight==}, {>>comment<<}

function Str(elem)
    local text = elem.text

    if FORMAT:match("html") then
        -- Handle addition: {++add++}
        text = text:gsub("{%+%+(.-)%+%+}", function(addition)
            return '<ins>' .. addition .. '</ins>'
        end)

        -- Handle deletion: {--delete--}
        text = text:gsub("{%-%-(.-)%-%-}", function(deletion)
            return '<del>' .. deletion .. '</del>'
        end)

        -- Handle substitution: {~~substitute~>replacement~~}
        text = text:gsub("{~~(.-)~>(.-)~~}", function(old, new)
            return '<del>' .. old .. '</del><ins>' .. new .. '</ins>'
        end)

        -- Handle highlight: {==highlight==}
        text = text:gsub("{==(.+)==}", function(highlight)
            return '<mark>' .. highlight .. '</mark>'
        end)

        -- Handle comment: {>>(.-)<<}
        text = text:gsub("{>>(.-)<<}", function(comment)
            return '<!-- ' .. comment .. ' -->'
        end)

    elseif FORMAT:match("latex") then
        -- Handle addition: {++add++}
        text = text:gsub("{%+%+(.-)%+%+}", function(addition)
            return '\\textcolor{blue}{' .. addition .. '}'
        end)

        -- Handle deletion: {--delete--}
        text = text:gsub("{%-%-(.-)%-%-}", function(deletion)
            return '\\textcolor{red}{\\st{' .. deletion .. '}}'
        end)

        -- Handle substitution: {~~substitute~>replacement~~}
        text = text:gsub("{~~(.-)~>(.-)~~}", function(old, new)
            return '\\textcolor{red}{\\sout{' .. old .. '}}\\textcolor{blue}{' .. new .. '}'
        end)

        -- Handle highlight: {==highlight==}
        text = text:gsub("{==(.+)==}", function(highlight)
            return '\\hl{' .. highlight .. '}'
        end)

        -- Handle comment: {>>(.-)<<}
        text = text:gsub("{>>(.-)<<}", function(comment)
            return '\\marginpar{' .. comment .. '}'
        end)

    elseif FORMAT:match("docx") then
        -- Handle addition: {++add++}
        text = text:gsub("{%+%+(.-)%+%+}", function(addition)
            return '<w:ins>' .. addition .. '</w:ins>'
        end)

        -- Handle deletion: {--delete--}
        text = text:gsub("{%-%-(.-)%-%-}", function(deletion)
            return '<w:del>' .. deletion .. '</w:del>'
        end)

        -- Handle substitution: {~~substitute~>replacement~~}
        text = text:gsub("{~~(.-)~>(.-)~~}", function(old, new)
            return '<w:del>' .. old .. '</w:del><w:ins>' .. new .. '</w:ins>'
        end)

        -- Handle highlight: {==highlight==}
        text = text:gsub("{==(.+)==}", function(highlight)
            return '<w:highlight w:val="yellow">' .. highlight .. '</w:highlight>'
        end)

        -- Handle comment: {>>(.-)<<}
        text = text:gsub("{>>(.-)<<}", function(comment)
            return '<w:comment>' .. comment .. '</w:comment>'
        end)
    end

    if text ~= elem.text then
        return pandoc.RawInline(FORMAT, text)
    end
    return text
end
