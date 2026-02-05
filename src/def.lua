---@meta blackjackalgamingfb-RGBTextGenerator
local public = {}
-- document whatever you made publicly available to other plugins here
-- use luaCATS annotations and give descriptions where appropriate
--  e.g. 
--	---@param a integer helpful description
--	---@param b string helpful description
--	---@return table c helpful description
--	function public.do_stuff(a, b) end

-- https://discord.com/channels/667753182608359424/1237738649484005469/1250904769162117140

---@class RGBTextObject
---@field public SetText fun(text: string): nil

---@param screen table
---@param key string
---@param text string
---@return RGBTextObject
function public.CreateRGBText(screen, key, text) end

return public
