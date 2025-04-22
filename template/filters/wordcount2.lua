-- wordcount.lua
-- Counts words, sentences, and paragraphs and adds to metadata
--
-- Usage: pandoc input.md --lua-filter wordcount.lua -o output.html
--
-- This filter provides detailed word count statistics:
-- - Total word count
-- - Sentence count
-- - Paragraph count
-- - Average words per sentence
-- - Average sentences per paragraph

function Pandoc(doc)
    -- Count words
    local words = 0
    local sentences = 0
    local paragraphs = 0
    local characters = 0
    local chars_no_spaces = 0
    
    pandoc.walk_block(pandoc.Div(doc.blocks), {
        Para = function(para)
            paragraphs = paragraphs + 1
            -- Count words in paragraph
            local text = pandoc.utils.stringify(para)
            words = words + select(2, text:gsub("%S+", ""))
            -- Count sentences (basic approximation)
            sentences = sentences + select(2, text:gsub("[%.!?]%s+", ""))
            -- Count characters
            characters = characters + text:len()
            chars_no_spaces = chars_no_spaces + select(2, text:gsub("%s", ""))
        end
    })
    
 	doc.meta.today  = os.date("%B %e, %Y")
    -- Add to metadata
    doc.meta.wordcount = pandoc.MetaMap({
        words = pandoc.MetaString(tostring(words)),
        sentences = pandoc.MetaString(tostring(sentences)),
        paragraphs = pandoc.MetaString(tostring(paragraphs)),
        characters = pandoc.MetaString(tostring(characters)),
        characters_no_spaces = pandoc.MetaString(tostring(chars_no_spaces)),
        avg_words_per_sentence = pandoc.MetaString(string.format("%.1f", words/math.max(1, sentences))),
        avg_sentences_per_paragraph = pandoc.MetaString(string.format("%.1f", sentences/math.max(1, paragraphs))),
        avg_paragraph_length = pandoc.MetaString(string.format("%.1f", words/math.max(1, paragraphs)))
    })
    
    return doc
end
