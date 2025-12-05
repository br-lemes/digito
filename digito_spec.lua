local empty = function() return { } end

_G._TEST = true
_G.iup = { dialog = empty, text = empty, hbox = empty, vbox = empty }
package.loaded["iuplua"] = _G.iup

local digito = require("digito")

describe("digito.calcdv", function()
	it("should calculate verification digit", function()
		assert.are.equal(5, digito.calcdv(0))
		assert.are.equal(4, digito.calcdv(1))
		assert.are.equal(0, digito.calcdv(8))
		assert.are.equal(5, digito.calcdv(12345678))
		assert.are.equal(5, digito.calcdv(99999999))
	end)
end)

describe("digito.sequencia", function()
	it("should handle single number", function()
		local result = digito.sequencia("AB", "00000001", "", "CD")
		assert.are.equal("AB000000014CD\n", result)
	end)

	it("should handle range of numbers", function()
		local result = digito.sequencia("AB", "00000001", "00000003", "CD")
		local expected = "AB000000014CD\nAB000000028CD\nAB000000031CD\n"
		assert.are.equal(expected, result)
	end)

	it("should handle reversed range", function()
		local result = digito.sequencia("AB", "00000003", "00000001", "CD")
		local expected = "AB000000014CD\nAB000000028CD\nAB000000031CD\n"
		assert.are.equal(expected, result)
	end)

	it("should limit range to 50 numbers", function()
		local result = digito.sequencia("AB", "00000001", "00000100", "CD")
		local _, count = result:gsub("\n", "")
		local first, last = result:sub(1, 13), result:sub(-14, -2)
		assert.are.equal(50, count)
		assert.are.equal("AB000000014CD", first)
		assert.are.equal("AB000000500CD", last)
	end)

	it("should handle empty or invalid inputs", function()
		assert.are.equal("", digito.sequencia("AB", "", "00000001", "CD"))
		assert.are.equal("", digito.sequencia("AB", "123", "00000001", "CD"))
	end)

	it("should convert letters to uppercase", function()
		local result = digito.sequencia("ab", "00000001", "", "cd")
		assert.are.equal("AB000000014CD\n", result)
	end)

	it("should handle nil or missing parameters", function()
		local result = digito.sequencia("AB", "00000001", "00000001")
		assert.are.equal("AB000000014\n", result)
		local result2 = digito.sequencia(nil, "00000001", "00000001")
		assert.are.equal("000000014\n", result2)
	end)
end)
