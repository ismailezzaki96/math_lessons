-- readability.lua
-- Calculates readability metrics for the document
--
-- Usage: pandoc input.md --lua-filter readability.lua -o output.html
--
-- This filter calculates several readability metrics:
-- - Flesch Reading Ease
-- - Flesch-Kincaid Grade Level
-- - Automated Readability Index
-- - Coleman-Liau Index

function Pandoc(doc)
    local text = pandoc.utils.stringify(doc.blocks)
    
    -- Count syllables (basic approximation)
    local function count_syllables(word)
        word = word:lower():gsub("[^a-z]", "")
        if word == "" then return 0 end
        
        -- Count vowel groups as syllables (rough approximation)
        local count = select(2, word:gsub("[aeiouy]+", ""))
        
        -- Handle special cases
        if word:match("e$") and not word:match("[aeiouy]e$") then 
            count = count - 1 
        end
        if count == 0 then count = 1 end
        
        return count
    end
    
    -- Extract words
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end
    
    local word_count = #words
    local syllable_count = 0
    local complex_words = 0  -- Words with 3+ syllables
    
    for _, word in ipairs(words) do
        local syll = count_syllables(word)
        syllable_count = syllable_count + syll
        if syll >= 3 then
            complex_words = complex_words + 1
        end
    end
    
    -- Count sentences (basic approximation)
    local sentence_count = select(2, text:gsub("[%.!?]%s+", ""))
    if sentence_count == 0 then sentence_count = 1 end
    
    -- Count characters
    local char_count = text:len()
    local char_no_spaces = select(2, text:gsub("%s", ""))
    
    -- Calculate Flesch Reading Ease
    -- 206.835 - 1.015 * (words/sentences) - 84.6 * (syllables/words)
    local flesch_ease = 206.835 - 1.015 * (word_count / sentence_count) - 84.6 * (syllable_count / word_count)
    
    -- Calculate Flesch-Kincaid Grade Level
    -- 0.39 * (words/sentences) + 11.8 * (syllables/words) - 15.59
    local fk_grade = 0.39 * (word_count / sentence_count) + 11.8 * (syllable_count / word_count) - 15.59
    
    -- Calculate Automated Readability Index
    -- 4.71 * (characters/words) + 0.5 * (words/sentences) - 21.43
    local ari = 4.71 * (char_no_spaces / word_count) + 0.5 * (word_count / sentence_count) - 21.43
    
    -- Calculate Coleman-Liau Index
    -- 0.0588 * L - 0.296 * S - 15.8
    -- Where L is average number of letters per 100 words
    -- And S is average number of sentences per 100 words
    local L = (char_no_spaces / word_count) * 100
    local S = (sentence_count / word_count) * 100
    local coleman_liau = 0.0588 * L - 0.296 * S - 15.8
    
    -- Calculate SMOG Index
    -- 1.043 * sqrt(complex_words * (30 / sentence_count)) + 3.1291
    local smog = 1.043 * math.sqrt(complex_words * (30 / sentence_count)) + 3.1291
    
    -- Interpret Flesch Reading Ease score
    local flesch_interpretation = ""
    if flesch_ease >= 90 then
        flesch_interpretation = "Very Easy - 5th grade level"
    elseif flesch_ease >= 80 then
        flesch_interpretation = "Easy - 6th grade level"
    elseif flesch_ease >= 70 then
        flesch_interpretation = "Fairly Easy - 7th grade level"
    elseif flesch_ease >= 60 then
        flesch_interpretation = "Standard - 8th-9th grade level"
    elseif flesch_ease >= 50 then
        flesch_interpretation = "Fairly Difficult - 10th-12th grade level"
    elseif flesch_ease >= 30 then
        flesch_interpretation = "Difficult - College level"
    else
        flesch_interpretation = "Very Difficult - College graduate level"
    end
    
    -- Add to metadata
    doc.meta.readability = pandoc.MetaMap({
        flesch_reading_ease = pandoc.MetaMap({
            score = pandoc.MetaString(string.format("%.1f", flesch_ease)),
            interpretation = pandoc.MetaString(flesch_interpretation)
        }),
        flesch_kincaid_grade = pandoc.MetaString(string.format("%.1f", fk_grade)),
        automated_readability_index = pandoc.MetaString(string.format("%.1f", ari)),
        coleman_liau_index = pandoc.MetaString(string.format("%.1f", coleman_liau)),
        smog_index = pandoc.MetaString(string.format("%.1f", smog)),
        syllables_per_word = pandoc.MetaString(string.format("%.2f", syllable_count / word_count)),
        complex_word_percentage = pandoc.MetaString(string.format("%.1f%%", (complex_words / word_count) * 100))
    })
    
    return doc
end
