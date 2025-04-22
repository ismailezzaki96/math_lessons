-- citation-counter.lua
-- A Pandoc Lua filter that counts all citations in a document

-- Initialize a table to store citation keys and their count
local citations = {}
local total_citations = 0

-- Function to process citations
function Cite(cite)
    -- Increment total citations count
    total_citations = total_citations + 1
    
    -- Loop through each citation in the current citation group
    for _, citation in ipairs(cite.citations) do
        local id = citation.id
        -- Increment citation count for this specific key
        if citations[id] then
            citations[id] = citations[id] + 1
        else
            citations[id] = 1
        end
    end
    
    -- Return the citation unchanged
    return cite
end

-- Function to finalize and print the results at the end of processing
function Pandoc(doc)
    -- Sort citation keys for consistent output
    local sorted_keys = {}
    for key in pairs(citations) do
        table.insert(sorted_keys, key)
    end
    table.sort(sorted_keys)
    
    -- Create metadata for citation statistics
    local meta = doc.meta
    
    -- Add citation statistics to metadata
    meta.citation_stats = {}
    meta.citation_stats.total_instances = pandoc.MetaString(tostring(total_citations))
    meta.citation_stats.unique_keys_count = pandoc.MetaString(tostring(#sorted_keys))
    
    -- Add list of unique citation keys to metadata
    local citation_keys = pandoc.MetaList({})
    for _, key in ipairs(sorted_keys) do
        table.insert(citation_keys, pandoc.MetaString(key))
    end
    meta.citation_stats.unique_keys = citation_keys
    
    -- Add citation counts to metadata
    local citation_counts = pandoc.MetaMap({})
    for _, key in ipairs(sorted_keys) do
        citation_counts[key] = pandoc.MetaString(tostring(citations[key]))
    end
    meta.citation_stats.counts = citation_counts
    
    -- Update document metadata
    doc.meta = meta
    
    
    return doc
end



