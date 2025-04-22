local arrows = {
  ["->"] = {unicode = "→", latex = "\\rightarrow"},
  ["<-"] = {unicode = "←", latex = "\\leftarrow"},
  ["<->"] = {unicode = "↔", latex = "\\leftrightarrow"},
  ["=>"] = {unicode = "⇒", latex = "\\Rightarrow"},
  ["<="] = {unicode = "⇐", latex = "\\Leftarrow"},
  ["<=>"] = {unicode = "⇔", latex = "\\Leftrightarrow"},
  ["-->"] = {unicode = "⟶", latex = "\\longrightarrow"},
  ["<--"] = {unicode = "⟵", latex = "\\longleftarrow"},
  ["<-->"] = {unicode = "⟷", latex = "\\longleftrightarrow"},
  ["==>"] = {unicode = "⟹", latex = "\\Longrightarrow"},
  ["<=="] = {unicode = "⟸", latex = "\\Longleftarrow"},
  ["<==>"] = {unicode = "⟺", latex = "\\Longleftrightarrow"},
  ["~>"] = {unicode = "⇝", latex = "\\rightsquigarrow"},
  ["<~"] = {unicode = "⇜", latex = "\\leftsquigarrow"},
  ["->>"] = {unicode = "↠", latex = "\\twoheadrightarrow"},
  ["<<-"] = {unicode = "↞", latex = "\\twoheadleftarrow"},
  [">->"] = {unicode = "↣", latex = "\\rightarrowtail"},
  ["<-<"] = {unicode = "↢", latex = "\\leftarrowtail"},
  ["|->"] = {unicode = "↦", latex = "\\mapsto"},
  ["<-|"] = {unicode = "↤", latex = "\\mapsfrom"},
  ["^->"] = {unicode = "↑", latex = "\\uparrow"},
  ["<-v"] = {unicode = "↓", latex = "\\downarrow"},
  ["^-v"] = {unicode = "↕", latex = "\\updownarrow"}
}

function Str(elem)
  if arrows[elem.text] then
    if FORMAT:match 'latex' then
      return pandoc.RawInline('latex', '$' .. arrows[elem.text].latex .. '$')
    elseif FORMAT:match 'html' or FORMAT:match 'docx' then
      return pandoc.Str(arrows[elem.text].unicode)
    else
      return elem
    end
  else
    return elem
  end
end
