-- TYPE

-- MAIN
---The discordia components library
---@class discordia_components
---@field public actionRow component_actionRow Making action row object
---@field public enums component_enums Enums of component module
---@field public button component_button Making button object
local this = {};

--ACTION ROW
---Handler for actionRow component
---@class component_actionRow
local component_actionRow = {};
---Create new action row containing childs components
---@return table actionRow table that containing childs components
function component_actionRow.new(childs) return {} end

--BUTTON
---@class component_button
local component_button = {};
---Create new button object
---@param props component_button_props struct of button object
---@return table
function component_button.new(props) return {} end
---@class component_button_props:table
---@field public custom_id string a developer-defined identifier for the component, max 100 characters
---@field public disabled boolean whether the component is disabled, default false
---@field public style component_enums_buttonStyle_child one of button styles
---@field public url string a url for link-style buttons
---@field public emoji Emoji name, id, and animated
---@field public label string text that appears on the button, max 80 characters
---@field public func function Making response

return this;
