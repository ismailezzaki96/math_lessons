local emojis = {
  [":!:"] = "❗️",
  [":?:"] = "❓️"
}

function Str(elem)
  if emojis[elem.text] then
    return pandoc.Str(emojis[elem.text])
  else
    return elem
  end
end
