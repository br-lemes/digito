
require("iuplua")

gui = { }

gui.dialog = iup.dialog{
	title = "Digito Verificador",
	font  = "HELVETICA_BOLD_12",
	iup.vbox{
		margin = "10x10",
		gap = "10",
		iup.hbox{
			margin = "0",
			iup.text{
				name  = "letras1",
				value = "RE",
				mask  = "/l/l",
				visiblecolumns = "2",
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
				visiblecolumns = "2",
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
	while elem[i] do
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
	if (dv == 0) then
		dv = 5
	elseif (dv == 10) then
		dv=0
	end
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
		gui.resultado.value = ""
		local n1 = gui.numeros1.value
		local n2 = gui.numeros2.value
		if n1 ~= "" and #n1 == 8 then
			if n2 == "" and #n2 ~= 8 then n2 = n1 end
			n1 = tonumber(n1)
			n2 = tonumber(n2)
			if n2 < n1 then n1, n2 = n2, n1 end
			if n2 - n1 > 50 then
				n2 = n1 + 50
			end
			for i = n1, n2 do
				gui.resultado.value = gui.resultado.value ..
					gui.letras1.value:upper() ..
						string.format("%08d", i) ..
						tostring(gui.calcdv(i)) ..
					gui.letras2.value:upper() .. "\n"
			end
		end
	end
end

gui.dialog:show()
iup.SetFocus(gui.numeros1)
iup.MainLoop()
