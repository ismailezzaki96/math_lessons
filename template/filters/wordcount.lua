-- counts words in a document
-- from https://pandoc.org/lua-filters.html#examples

words = 0

wordcount = {
	Str = function(el)
		-- we don't count a word if it's entirely punctuation:
		if el.text:match("%P") then
			words = words + 1
		end
	end,
}

function Pandoc(doc)
	-- skip metadata, just count body:
	pandoc.walk_block(pandoc.Div(doc.blocks), wordcount)

	-- Add word count to metadata
	doc.meta.word_count = words
 	doc.meta.today  = os.date("%B %e, %Y")
	-- Print word count (optional, you can remove this line if you don't need it)
	print(words .. " words in body")
  print("Draft compiled on " .. doc.meta.today)

	return doc
end
