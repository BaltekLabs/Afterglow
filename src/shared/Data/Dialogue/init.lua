--[[
	Dialogue trees, one module per speaker. Format:

	{
	  name = "Speaker Name",
	  entry = { { when = {conditions}, node = "id" }, ..., { node = "default" } },  -- first match wins
	  nodes = {
	    id = {
	      text = "Line. {player} / {first} are replaced with the protagonist's name.",
	      textBy = { mara = "Character-specific override." },
	      speaker = "Optional override",
	      effects = { ... },   -- applied when the node is shown
	      next = "id",         -- used when there are no choices ("Continue")
	      choices = {
	        { text = "Option", when = {conditions}, effects = { ... }, next = "id" },  -- no next = end
	      },
	    },
	  },
	}
]]
local Dialogue = {}

for _, child in ipairs(script:GetChildren()) do
	if child:IsA("ModuleScript") then
		Dialogue[child.Name] = require(child)
	end
end

return Dialogue
