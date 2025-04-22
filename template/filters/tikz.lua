local function tikz2image(src, outfile)
	-- Open the file
	local file, err = io.open("filters/template.tex", "r")

	-- Check if the file was opened successfully
	if not file then
		print("Could not open file: ", err)
		return
	end

	-- Read the file content
	local content = file:read("*all")

	-- Close the file
	file:close()
	local tmp = os.tmpname()
	local tmpdir = string.match(tmp, "^(.*[\\/])") or "."
	local f = io.open(tmp .. ".tex", "w")
	if f == nil then
		print("Could not open file: ", tmp .. ".tex")
		return
	end
	f:write(content)
	f:write(src)
	f:write("\n\\end{document}\n")
	f:close()
	os.execute("pdflatex -output-directory " .. tmpdir .. " " .. tmp)
	os.execute("pdflatex -output-directory " .. tmpdir .. " " .. tmp)
	os.execute("inkscape -D -z --file=" .. tmp .. ".pdf --export-plain-svg=" .. outfile)
	-- os.execute("convert -density 300  " .. tmp .. ".pdf " .. outfile)
	-- os.remove(tmp .. ".tex")
	-- os.remove(tmp .. ".pdf")
	-- os.remove(tmp .. ".log")
	-- os.remove(tmp .. ".aux")
end

local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function CodeBlock(el)
	-- Don't alter element if it's not a tikzpicture environment
	-- if not el.text:match("^\\begin{tikzpicture}") then
	--       io.stderr:write("Cannot open file " .. cb.attributes.include .. " | Skipping includes\n")
	io.stderr:write("CodeBlock: " .. el.classes[1] .. "\n")
	if el.classes[1] == "latex" then
		local fname = "./images/" .. pandoc.sha1(el.text) .. ".svg"
		if not file_exists(fname) then
			tikz2image(el.text, fname)
		end
		return pandoc.Para({ pandoc.Image({}, fname) })
	else
		return nil
	end

	if not el.classes[1] == "latex" then
		return nil
		-- Alternatively, parse the contained LaTeX now:
		-- return pandoc.read(el.text, 'latex').blocks
	end
	local fname = "./images/" .. pandoc.sha1(el.text) .. ".svg"
	if not file_exists(fname) then
		tikz2image(el.text, fname)
	end
	return pandoc.Para({ pandoc.Image({}, fname) })
end
