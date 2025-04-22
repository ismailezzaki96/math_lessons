-- section-word-counts.lua
-- Analyzes word count by section
--
-- Usage: pandoc input.md --lua-filter section-word-counts.lua -o output.html
--
-- This filter tracks word counts for each section/heading in the document
-- and analyzes the distribution of content across the document.

function Pandoc(doc)
    local sections = {}
    local current_section = {title = "Introduction", level = 0, words = 0}
    local total_words = 0
    local current_words = 0
    
    -- First pass: collect sections and word counts
    for i, block in ipairs(doc.blocks) do
        if block.t == "Header" then
            -- Save the previous section with its word count
            if current_words > 0 then
                current_section.words = current_words
                table.insert(sections, current_section)
                total_words = total_words + current_words
            end
            
            -- Start a new section
            current_section = {
                title = pandoc.utils.stringify(block),
                level = block.level,
                words = 0
            }
            current_words = 0
        else
            -- Count words in this block
            local text = pandoc.utils.stringify(block)
            local block_words = select(2, text:gsub("%S+", ""))
            current_words = current_words + block_words
        end
    end
    
    -- Add the final section
    if current_words > 0 then
        current_section.words = current_words
        table.insert(sections, current_section)
        total_words = total_words + current_words
    end
    
    -- Add total word count in case it's different from wordcount.lua
    if total_words == 0 then
        total_words = 1  -- Avoid division by zero
    end

	-- keep only level 0 and 1 sections
		sections = pandoc.List:new(sections):filter(function(section)
				return section.level == 0 or section.level == 1
		end)
	-- ignore references section
		sections = pandoc.List:new(sections):filter(function(section)
				return section.title:lower() ~= "references"
		end)
	-- remove the word count of the references section
	total_words = total_words - sections[#sections].words
    
    -- Second pass: calculate percentages and create metadata
    local section_meta = pandoc.MetaList({})
    for _, section in ipairs(sections) do
        local percentage = (section.words / total_words) * 100
        local meta_section = pandoc.MetaMap({
            title = pandoc.MetaString(section.title),
            level = pandoc.MetaString(tostring(section.level)),
            words = pandoc.MetaString(tostring(section.words)),
            percentage = pandoc.MetaString(string.format("%.1f%%", percentage))
        })
        table.insert(section_meta, meta_section)
    end
    
    -- Calculate basic statistics about section distribution
    local section_count = #sections
    local avg_section_length = total_words / section_count
    local longest_section = 0
    local shortest_section = total_words
    local longest_title = ""
    local shortest_title = ""
    
    for _, section in ipairs(sections) do
        if section.words > longest_section then
            longest_section = section.words
            longest_title = section.title
        end
        if section.words < shortest_section then
            shortest_section = section.words
            shortest_title = section.title
        end
    end
    
    -- Add section analysis metadata
    doc.meta.section_analysis = pandoc.MetaMap({
        sections = section_meta,
        total_sections = pandoc.MetaString(tostring(section_count)),
        total_words = pandoc.MetaString(tostring(total_words)),
        avg_section_length = pandoc.MetaString(string.format("%.1f", avg_section_length)),
        longest_section = pandoc.MetaMap({
            title = pandoc.MetaString(longest_title),
            words = pandoc.MetaString(tostring(longest_section)),
            percentage = pandoc.MetaString(string.format("%.1f%%", (longest_section / total_words) * 100))
        }),
        shortest_section = pandoc.MetaMap({
            title = pandoc.MetaString(shortest_title),
            words = pandoc.MetaString(tostring(shortest_section)),
            percentage = pandoc.MetaString(string.format("%.1f%%", (shortest_section / total_words) * 100))
        })
    })
    
    return doc
end
