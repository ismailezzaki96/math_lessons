function Math(elem)
	return pandoc.RawInline("html", pandoc.utils.stringify(elem))
end
