function Code(block)
	local lang = block.classes[1]
	if lang == "python" then
		if not block.identifier or block.identifier == "" then
			return block
		end

		local file_extension
		local source_file
		local output_file
		local executable

		file_extension = "py"
		source_file = block.identifier .. "." .. file_extension
		output_file = block.identifier .. "_output.txt"
		executable = "python"

		local source_handle = io.open(source_file, "w")
		source_handle:write(block.text)
		source_handle:close()

		local handle = io.popen(executable .. " " .. source_file .. " 2>&1")
		local output_text = handle:read("*a")
		handle:close()

		local output_block = pandoc.Str(output_text, "text")

		local blocks = pandoc.List({ block, output_block })

		os.remove(source_file)
		os.remove(output_file)

		return output_block
	end

	return block
end
