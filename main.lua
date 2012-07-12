
local ascii85 = require "ascii85"



local input = "Man is distinguished, not only by his reason, but by this singular passion from other animals, which is a lust of the mind, that by a perseverance of delight in the continued and indefatigable generation of knowledge, exceeds the short vehemence of any carnal pleasure."

local enc = ascii85.encode(input)
print(enc)

local dec = ascii85.decode(enc)
print(dec)