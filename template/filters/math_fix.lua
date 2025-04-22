eq_count = 0

function Math(math)
		if math.mathtype == "DisplayMath" then
			if not math.text:find("\\label") then
				-- if not math.text:find("#eq") then
				return pandoc.RawInline(
					"latex",
					"\n\\begin{equation}" .. math.text .. "\\quad \\end{equation}"
					-- "\n\\begin{equation}" .. math.text .. "\\end{equation}{.eq:" .. eq_count .. "}"
				)
			end
		end
	end

-- function Math(math)
--   -- print Format
--   format = FORMAT
--   print(format)
--
--   if FORMAT:match 'html5' then
--     if math.mathtype == "DisplayMath" then
--         return pandoc.RawInline("html", "<div class=\"math\">\\[" .. math.text .. "\\]</div>")
--     elseif math.mathtype == "InlineMath" then
--         return pandoc.RawInline("html", "<span class=\"math\">\\(" .. math.text .. "\\)</span>")
--     end
--   end
--   if FORMAT:match 'latex' then
--     if math.mathtype == "DisplayMath" then
--         return pandoc.RawInline("latex", "\n\\begin{equation*}" .. math.text .. "\\end{equation*}\n")
--     elseif math.mathtype == "InlineMath" then
--         return pandoc.RawInline("latex", "$" .. math.text .. "$")
--     end
--   end
-- end
