
require("iuplua")

gui = { }

gui.dialog = iup.dialog{
	title = "Digito Verificador",
	font  = "Helvetica, Bold 12",
	iup.vbox{
		margin = "10x10",
		gap = "10",
		iup.hbox{
			margin = "0",
			iup.text{
				name  = "letras1",
				value = "RE",
				mask  = "/l/l",
				visiblecolumns = "3",
			},
			iup.text{
				name = "numeros1",
				mask = "/d/d/d/d/d/d/d/d",
				visiblecolumns = "8",
			},
			iup.text{
				name = "numeros2",
				mask = "/d/d/d/d/d/d/d/d",
				visiblecolumns = "8",
			},
			iup.text{
				name  = "letras2",
				value = "BR",
				mask  = "/l/l",
				visiblecolumns = "3",
			},
		},
		iup.text{
			name      = "resultado",
			expand    = "YES",
			multiline = "YES",
			visiblelines = "10",
		},
	}
}

function gui.iupnames(self, elem)
	if type(elem) == "userdata" then
		if elem.name ~= "" and elem.name ~= nil then
			self[elem.name] = elem
		end
	end
	local i = 1
	while elem and elem[i] do
		self:iupnames(elem[i])
		i = i + 1
	end
end

gui:iupnames(gui.dialog)

function gui.calcdv(xreg)
	local dv = 0
	xreg = string.format("%08d", xreg)
	dv = tonumber(xreg:sub(1,1))*8
	dv = dv + tonumber(xreg:sub(2,2))*6
	dv = dv + tonumber(xreg:sub(3,3))*4
	dv = dv + tonumber(xreg:sub(4,4))*2
	dv = dv + tonumber(xreg:sub(5,5))*3
	dv = dv + tonumber(xreg:sub(6,6))*5
	dv = dv + tonumber(xreg:sub(7,7))*9
	dv = dv + tonumber(xreg:sub(8,8))*7
	dv = dv * 10
	dv = dv % 11
	if (dv == 0) then return 5 end
	if (dv == 10) then return 0 end
	return dv
end

function gui.question(message)
	local dlg = iup.messagedlg{
		title      = "Confirmar",
		value      = message,
		buttons    = "YESNO",
		dialogtype = "QUESTION"
	}
	dlg:popup()
	return dlg.buttonresponse == "1"
end

function gui.dialog:close_cb()
	if gui.question("Sair do Digito Verificador?") then
		self:hide()
	else
		return iup.IGNORE
	end
end

function gui.dialog:k_any(k)
	if k == iup.K_ESC then
		self:close_cb()
	elseif k == iup.K_CR then
		gui.resultado.value = gui.sequencia(
			gui.letras1.value,
			gui.numeros1.value,
			gui.numeros2.value,
			gui.letras2.value
		)
	end
end

function gui.sequencia(letras1, numeros1, numeros2, letras2)
	if numeros1 == "" or #numeros1 ~= 8 then return "" end
	if numeros2 == "" or #numeros2 ~= 8 then numeros2 = numeros1 end
	numeros1 = tonumber(numeros1)
	numeros2 = tonumber(numeros2)
	if numeros1 > numeros2 then numeros1, numeros2 = numeros2, numeros1 end
	if numeros2 - numeros1 > 50 then numeros2 = numeros1 + 49 end
	letras1 = (letras1 or ""):upper()
	letras2 = (letras2 or ""):upper()
	local resultados = {}
	for i = numeros1, numeros2 do
		local dv = gui.calcdv(i)
		local resultado = string.format("%s%08d%d%s\n", letras1, i, dv, letras2)
		table.insert(resultados, resultado)
	end
	return table.concat(resultados)
end

if _TEST then
	return { calcdv = gui.calcdv, sequencia = gui.sequencia }
end

gui.dialog:show()
iup.SetFocus(gui.numeros1)
iup.MainLoop()
