-- Brainfuck parser by Xan

local printMemoryInHex = true
-- Brainfuck code
local code = "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
-- Input args
local input = ""

local index = 0
local inputindex = 1
local memory = {}
setmetatable(memory, {
	__index = function (tbl, idx)
		if tbl ~= memory then return tbl[idx] end
		local val = rawget(memory, idx)
		if val == nil then
			rawset(memory, idx, 0)
			return 0
		else
			return val
		end
	end;
	__newindex = function (tbl, idx, val)
		if tbl ~= memory then tbl[idx] = val return end
		assert(type(val) == "number" and (math.floor(val) == val) and (val >= 0) and (val < 256), "Error: Number value is incorrect (either not a number, not a whole number, < 0, or > 255 (Value Type: " .. type(val) .. " Value: " .. val .. ")")
		rawset(memory, idx, val)
	end
})


local jumps = {}
local jumpexits = {}
local output = ""
local idx = 1
while idx <= #code do
	local char = code:sub(idx, idx)
	if char == ">" then
		index = index + 1
	elseif char == "<" then
		index = index - 1
	elseif char == "+" then
		memory[index] = memory[index] + 1
	elseif char == "-" then
		memory[index] = memory[index] - 1
	elseif char == "[" then
		-- gotta find the closing ]
		local exit = nil
		if not jumps[idx] then
			local depth = 1
			for idx2 = idx + 1, #code do
				local chr2 = code:sub(idx2, idx2)
				if chr2 == "[" then
					depth = depth + 1
				elseif chr2 == "]" then
					depth = depth - 1
					if depth == 0 then
						jumpexits[idx2] = idx - 1 -- This ensures we run into the [ again
						exit = idx2
						break
					end
				end
			end
			if not exit then
				error("loose [ without a buddy :(")
			end
			jumps[idx] = exit
		end
		if memory[index] == 0 then
			idx = jumps[idx]
		end
	elseif char == "]" then
		if jumpexits[idx] then
			idx = jumpexits[idx]
		else
			error("loose ] without a buddy :(")
		end
	elseif char == "." then
		output = output .. string.char(memory[index])
	elseif char == "," then
		if inputindex <= #code then
			local c = input:sub(inputindex, inputindex)
			memory[index] = string.byte(c)
			inputindex = inputindex + 1
		else
			memory[index] = 0
		end
	end
	idx = idx + 1
end


print("CURRENT POINTER: " .. index)
print("MEMORY DUMP:")
for i = 0, 50 do
	local memdump = ""
	for j = 0, 11 do
		if not printMemoryInHex then
			memdump = memdump .. string.format("%03d", memory[(i * 10) + j]) .. " "
		else
			memdump = memdump .. string.format("0x%02x", memory[(i * 10) + j]) .. " "
		end
	end
	print(memdump)
end
print("\nRESULT: " .. output)