-- capitalize_headings.lua
-- A Pandoc Lua filter to capitalize the first letter of all headings and title

-- Helper function to capitalize the first letter of a string
function capitalize_first(s)
  if s and s ~= "" then
    return s:sub(1,1):upper() .. s:sub(2)
  else
    return s
  end
end

-- Process all headers in the document
function Header(el)
  -- Process each element in the header content
  for i, item in ipairs(el.content) do
    if item.t == "Str" and i == 1 then
      -- Capitalize the first string in the header
      item.text = capitalize_first(item.text)
    end
  end
  return el
end

-- Process the document title if present in metadata
function Meta(meta)
  if meta.title then
    if meta.title.t == "MetaInlines" then
      -- If title is a simple string or inline elements
      for i, item in ipairs(meta.title) do
        if item.t == "Str" and i == 1 then
          -- Capitalize the first string in the title
          item.text = capitalize_first(item.text)
        end
      end
    elseif meta.title.t == "MetaBlocks" then
      -- If title is a block element (less common)
      for _, block in ipairs(meta.title) do
        if block.t == "Para" or block.t == "Plain" then
          for i, inline in ipairs(block.content) do
            if inline.t == "Str" and i == 1 then
              inline.text = capitalize_first(inline.text)
            end
          end
        end
      end
    end
  end
  return meta
end

local function is_space_before_author_in_text(spc, cite)
  return spc and spc.t == 'Space'
    and cite and cite.t == 'Cite'
    -- there must be only a single citation, and it must have
    -- mode 'AuthorInText'
    and #cite.citations == 1
    and cite.citations[1].mode == 'AuthorInText'
end

function Inlines (inlines)
  -- Go from end to start to avoid problems with shifting indices.
  for i = #inlines-1, 1, -1 do
    if is_space_before_author_in_text(inlines[i], inlines[i+1]) then
      inlines:remove(i)
    end
  end
  return inlines
end

-- Return the filter as a table with the functions to apply
return {
  Header = Header,
  Meta = Meta,
	Inlines = Inlines
}
