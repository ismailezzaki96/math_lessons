-- mathjax-svg.lua

local system = require("pandoc.system")
local sha1 = pandoc.utils.sha1

-- Directory to store generated SVG images
local svg_dir = "svg"

-- Ensure the svg_dir exists
os.execute("mkdir -p " .. svg_dir)

-- Function to read SVG dimensions and remove 'ex' units
local function get_svg_dimensions(svg_file)
	local file = io.open(svg_file, "r")
	if not file then
		return nil, nil
	end
	local content = file:read("*all")
	file:close()

	-- Remove 'ex' units from width and height
	local modified = false
	content, modified = content:gsub('width="([%d%.]+)ex"', 'width="%1"')
	content = content:gsub('height="([%d%.]+)ex"', 'height="%1"')

	-- If modifications were made, write back to the SVG file
	if modified > 0 then
		local file = io.open(svg_file, "w")
		file:write(content)
		file:close()
	end

	-- Extract width and height from modified content
	local width = content:match('width="([%d%.]+)"')
	local height = content:match('height="([%d%.]+)"')

	-- If width and height are not found, try to extract viewBox and compute dimensions
	if not width or not height then
		local viewBox = content:match('viewBox="([%d%.%- ]+)"')
		if viewBox then
			local minx, miny, vb_width, vb_height = viewBox:match("([%d%.%-]+) ([%d%.%-]+) ([%d%.%-]+) ([%d%.%-]+)")
			width = vb_width
			height = vb_height
		end
	end

	return width, height
end
-- Function to convert LaTeX math to SVG using MathJax-node
local function math_to_svg(math_el)
	local math_text = math_el.text
	local display = math_el.mathtype == "DisplayMath"
	local fname = svg_dir .. "/" .. sha1(math_text) .. ".svg"

	-- Check if SVG already exists
	local svg_exists = io.open(fname, "r")
	if svg_exists then
		svg_exists:close()
	else
		local options = display and " --linebreaks" or " --inline "
		command = "tex2svg" .. options .. ' "' .. math_text:gsub('"', '\\"') .. '"  > ' .. fname
		os.execute(command)
	end

	-- Set image attributes based on math type
	local img_attr = {}
	if display then
		-- For display math, set a larger size
		img_attr = { width = "25%", style = "display: block; margin: 10px auto;" }
	else
		-- For inline math, set a smaller size
		img_attr = { height = "1.2em", style = "vertical-align: -0.1em;" }
	end
	-- Create an Image element with attributes
	local img = pandoc.Image({ pandoc.Str("") }, fname)
	img.attributes = img_attr
	local width, height = get_svg_dimensions(fname)

	if width and height then
		-- Optionally apply a scaling factor
		local scale = 7.0 -- Adjust the scale as needed

		-- Convert width and height to numbers
		width = tonumber(width)
		height = tonumber(height)

		-- Units conversion if needed (e.g., from ex to pt)
		-- Assuming 1ex ≈ 4.3pt (adjust as needed)
		-- Since we've removed 'ex', we can decide units ourselves

		-- Apply scaling
		width = width * scale
		height = height * scale

		-- Set width and height attributes with units (e.g., pt)
		img.attributes.width = string.format("%.2fpt", width)
		img.attributes.height = string.format("%.2fpt", height)
	end
	return img
end

-- Pandoc filter
function Math(el)
	return math_to_svg(el)
end

function InlineMath(el)
	return math_to_svg(el)
end
