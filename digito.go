package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"

	"github.com/gen2brain/iup-go/iup"
)

func main() {
	iup.Open()
	defer iup.Close()

	iup.SetGlobal("UTF8", "YES")

	dlg := iup.Dialog(
		iup.Vbox(
			iup.Hbox(
				iup.Text().
					SetAttribute("NAME", "letras1").
					SetAttribute("VALUE", "RE").
					SetAttribute("MASK", "/l/l").
					SetAttribute("VISIBLECOLUMNS", "3"),
				iup.Text().
					SetAttribute("NAME", "numeros1").
					SetAttribute("MASK", "/d/d/d/d/d/d/d/d").
					SetAttribute("VISIBLECOLUMNS", "8"),
				iup.Text().
					SetAttribute("NAME", "numeros2").
					SetAttribute("MASK", "/d/d/d/d/d/d/d/d").
					SetAttribute("VISIBLECOLUMNS", "8"),
				iup.Text().
					SetAttribute("NAME", "letras2").
					SetAttribute("VALUE", "BR").
					SetAttribute("MASK", "/l/l").
					SetAttribute("VISIBLECOLUMNS", "3"),
			).SetAttribute("MARGIN", "0"),
			iup.Text().
				SetAttribute("NAME", "resultado").
				SetAttribute("EXPAND", "YES").
				SetAttribute("MULTILINE", "YES").
				SetAttribute("VISIBLELINES", "10"),
		).
			SetAttribute("GAP", "10").
			SetAttribute("MARGIN", "10x10"),
	).
		SetAttribute("FONT", "Helvetica, Bold 12").
		SetAttribute("TITLE", "Digito Verificador").
		SetCallback("CLOSE_CB", iup.CloseFunc(onClose)).
		SetCallback("K_ANY", iup.KAnyFunc(onKey))

	iup.Show(dlg)
	iup.MainLoop()
}

func CalcDV(xreg int) int {
	dv := 0
	weights := []int{8, 6, 4, 2, 3, 5, 9, 7}
	numDigits := 8

	for i := 0; i < numDigits; i++ {
		divisor := int(math.Pow(10, float64(numDigits-1-i)))
		digit := (xreg / divisor) % 10
		dv += digit * weights[i]
	}

	dv = dv * 10
	dv = dv % 11
	if dv == 0 {
		return 5
	}
	if dv == 10 {
		return 0
	}
	return dv
}

func question(message string) bool {
	dlg := iup.MessageDlg().
		SetAttribute("TITLE", "Confirmar").
		SetAttribute("VALUE", message).
		SetAttribute("BUTTONS", "YESNO").
		SetAttribute("DIALOGTYPE", "QUESTION")
	iup.Popup(dlg, iup.CENTER, iup.CENTER)
	return dlg.GetInt("BUTTONRESPONSE") == 1
}

func onClose(ih iup.Ihandle) int {
	if question("Sair do Digito Verificador?") {
		return iup.CLOSE
	} else {
		return iup.IGNORE
	}
}

func onKey(ih iup.Ihandle, k int) int {
	switch {
	case k == iup.K_ESC:
		return onClose(ih)
	case k == iup.K_CR:
		iup.GetDialogChild(ih, "resultado").SetAttribute("VALUE", Sequencia(
			iup.GetDialogChild(ih, "letras1").GetAttribute("VALUE"),
			iup.GetDialogChild(ih, "numeros1").GetAttribute("VALUE"),
			iup.GetDialogChild(ih, "numeros2").GetAttribute("VALUE"),
			iup.GetDialogChild(ih, "letras2").GetAttribute("VALUE"),
		))
	}
	return iup.CONTINUE
}

func Sequencia(letras1, numeros1, numeros2, letras2 string) string {
	if numeros1 == "" || len(numeros1) != 8 {
		return ""
	}
	if numeros2 == "" || len(numeros2) != 8 {
		numeros2 = numeros1
	}
	num1, _ := strconv.Atoi(numeros1)
	num2, _ := strconv.Atoi(numeros2)
	if num1 > num2 {
		num1, num2 = num2, num1
	}
	if num2-num1 > 50 {
		num2 = num1 + 49
	}
	letras1 = strings.ToUpper(letras1)
	letras2 = strings.ToUpper(letras2)
	var resultados []string
	for i := num1; i <= num2; i++ {
		resultado := fmt.Sprintf("%s%08d%d%s\n", letras1, i, CalcDV(i), letras2)
		resultados = append(resultados, resultado)
	}
	return strings.Join(resultados, "")
}
