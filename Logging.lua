--[[
	Logging utility implemented in lua for use in Dota 2 custom gamemodes. Allows the user
	to add entry under a certain label. This entry can be strings, numbers lists or objects.
	Note: To define a list make sure it has .type = 'list'. For example: list = {'a','b','c',[type]='list'}.
	This log can be parsed to JSON.

	ExampleCode:
	
	--Create a log instance (you can have more than one!)
	local l = LOG.new()

	--Add a value to the log
	l:add('Winner', 'A')

	--Add multiple values of the same key
	l:add('Players', 'A')
	l:add('Players', 'X')
	l:add('Players', 'Y')
	l:add('Players', 'Z')

	--Build some data object
	local rounds = {
		Round1 = {
			Winner='A',
			Duration=45,
			Kills= {
				{player='A', killed='X', timeStamp=20},
				{player='Z', killed='Y', timeStamp=20},
				{player='A', killed='Z', timeStamp=45},
				['type'] = 'list'
			}
		}, Round2 = {
			Winner='A'
		}
	}

	--Adding an object
	l:add('Rounds', rounds)

	--Get a JSON string representing the log
	print(l:toJSON())

	Author: Perry
]]
LOG = {}
LOG.__index = LOG

--construct a LOG object
function LOG.new()
   local log = {}             -- our new object
   setmetatable(log, LOG)
   
   log.logObj = {}
   return log
end

--Add an entry with a label
--Params:	key - the label for the entry
--			value - the entry (String, number, list or object)
function LOG:add( key, value )
	if not self.logObj[key] then
		self.logObj[key] = {}
	end

	self.logObj[key][#self.logObj[key] + 1] = value
end

--Get all entries for a certain label
--Params:	key - the label to retrieve data for
function LOG:get( key )
	return self.logObj[key]
end

--Get a JSON representation of this log
function LOG:toJSON()
	local output = "{"
	for k,v in pairs(self.logObj) do
		if #v == 1 then
			output = output..'"'..k..'" : '..self:ObjectToJSON( v[1] )
			output = output..","
		elseif #v > 1 then
			output = output..'"'..k..'" : '..self:ListToJSON( v )
			output = output..","
		end
	end
	output = output.."}"
	output, n = output:gsub(",}", "}")
	return output
end

--Get a JSON representation of a list
--Params:	list - the list to parse
function LOG:ListToJSON( list )
	local output = "["

	for k,v in pairs(list) do
		output = output..self:ObjectToJSON( v )
		output = output..","
	end

	output = output.."]"
	output, n = output:gsub(",]", "]")
	return output
end

--Get a JSON representation of an object
--Params: obj - the object to convert to JSON
function LOG:ObjectToJSON( obj )
	if type(obj) == 'table' then
		
		if obj.type == 'list' then
			obj.type = nil
			str = self:ListToJSON(obj)
			obj.type = 'list'
			return str
		end

		local str = '{'
		for k,v in pairs(obj) do
			str = str..'"'..k..'" : '..self:ObjectToJSON(v)..","
		end

		str = str..'}'
		str, n = str:gsub(',}','}')
		return str
	else
		if type(obj) == 'number' then
			return obj
		else
			return '"'..obj..'"'
		end
	end
end