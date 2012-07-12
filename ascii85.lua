


--====================================================================--
-- Module: Ascii 85 Encoding in Pure Lua
-- Author : Satheesh
-- 
-- License:
--
--    Permission is hereby granted, free of charge, to any person obtaining a copy of 
--    this software and associated documentation files (the "Software"), to deal in the 
--    Software without restriction, including without limitation the rights to use, copy, 
--    modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
--    and to permit persons to whom the Software is furnished to do so, subject to the 
--    following conditions:
-- 
--    The above copyright notice and this permission notice shall be included in all copies 
--    or substantial portions of the Software.
-- 
--    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
--    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
--    PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
--    FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
--    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
--    DEALINGS IN THE SOFTWARE.
--
-- Overview: 
--
--    This module can be used to verify and validate auto-renewable in-app purchases using Corona
--
--
-- Version : 1.0 
--
--
-- Usage:
--
--
-- local validate = require "validate"
-- validate.start
-- {
-- receipt = "Your Receipt Here",
-- password = "Your shared secret key here",
-- listener = listener,				
-- testing = true,					--Should be true if you use sandbox receipt, false if you use actual receipt

--The following lines must be uncommented if you want your receipt to be verified by your server.
--The php for receipt verification is also included within the project
--[[							
serverValidation = true,
serverLink = "Link of your php file"
--]]

--
--====================================================================--
--




local function decimalToBase85(num)
	local base = 85
	
	local final = {}
	while num > 0 do
		table.insert(final,1,num % base)
		num = math.floor(num / base)
	end
	
	return final
end



local function base85ToDecimal(b85)
	local base = 85
	 
	local l = #b85
	local final = 0
	
	for i=l,1,-1 do 
		local digit = b85[i]
		local val = digit * base^(l-i)
		final = final + val
	end 
	
	return final 
end 


local function decimalToBinary(num)
	local base = 2
	local bits = 8 
	
	local final = ""
	while num > 0 do
		final = "" ..  (num % base ) .. final
		num = math.floor(num / base)
	end
	
	local l = final:len()
	if l == 0 then 
		final = "0"..final 
	end
	
	while final:len()%8 ~=0 do 
		final = "0"..final 
	end 
	
	return final
end


local function binaryToDecimal(bin)
	local base = 2 
	 
	local l = bin:len()
	local final = 0
	
	for i=l,1,-1 do 
		local digit = bin:sub(i,i)
		local val = digit * base^(l-i)
		final = final + val
	end 
	return final 
end 




local function encode(substr)
	
	local l = substr:len()
	local combine = ""
	for i=1,l do 
		local char = substr:sub(i,i)
		local byte = char:byte()
		local bin = decimalToBinary(byte)
		combine = combine..bin
	end 
	
	local num = binaryToDecimal(combine)
	local b85 = decimalToBase85(num)
	
	local final = ""
	for i=1,#b85 do 
		local char = tostring(b85[i]+33)
		final = final .. char:char()
	end 
	
	return final 
end 



local function decode(substr)

	local final = "" 
	
	local l = substr:len()
	local combine = {}
	for i=1,l do 
		local char = substr:sub(i,i)
		local byte = char:byte()	
		byte = byte - 33 
		combine[i] = byte
	end 
	
	local num = base85ToDecimal(combine)	
	local bin = decimalToBinary(num)

	
	local l = bin:len()
	local split = 8 
	for i=1,l,split do 
		local sub = bin:sub(i,i+split-1)
		local byte = binaryToDecimal(sub)
		local char = tostring(byte):char()
		final = final..char
	end 
	
	return final
end 



local function ascii_encode(str)
	
	
	local final = ""
	
	local noOfZeros = 0
	while str:len()%4~=0 do 	
		noOfZeros =  noOfZeros + 1 
		str = str.."\0"
	end
	
	local l = str:len()
	
	for i=1,l,4 do 
		local sub = str:sub(i,i+3)
		final = final .. encode(sub)
	end 

	final = final:sub(1,-noOfZeros-1)
	final = "<~"..final.."~>"
	return final 

end


local function ascii_decode(str)
	
	local final = ""
	
	str = str:sub(3,-3)
	
	local c = 5 
	local noOfZeros = 0
	while str:len()%c~=0 do 	
		noOfZeros =  noOfZeros + 1 
		str = str.."u"
	end

	
	local l = str:len()
	for i=1,l,c do 
		local sub = str:sub(i,i+c-1)
		final = final .. decode(sub)
	end 
	
	final = final:sub(1,-noOfZeros-1)
	return final 
	
	
	
	
end 



return {encode = ascii_encode,decode = ascii_decode}




