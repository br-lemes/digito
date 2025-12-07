package main

import (
	"strings"
	"testing"
)

func TestCalcDV(t *testing.T) {
	testCases := []struct {
		name  string
		input int
		want  int
	}{
		{name: "Input 0", input: 0, want: 5},
		{name: "Input 1", input: 1, want: 4},
		{name: "Input 8", input: 8, want: 0},
		{name: "Input 12345678", input: 12345678, want: 5},
		{name: "Input 99999999", input: 99999999, want: 5},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			got := CalcDV(tc.input)
			if got != tc.want {
				t.Errorf("CalcDV(%d) = %d; want %d", tc.input, got, tc.want)
			}
		})
	}
}

func TestSequencia(t *testing.T) {
	testCases := []struct {
		name     string
		letras1  string
		numeros1 string
		numeros2 string
		letras2  string
		want     string
	}{
		{
			name:     "should handle single number",
			letras1:  "AB",
			numeros1: "00000001",
			numeros2: "",
			letras2:  "CD",
			want:     "AB000000014CD\n",
		},
		{
			name:     "should handle range of numbers",
			letras1:  "AB",
			numeros1: "00000001",
			numeros2: "00000003",
			letras2:  "CD",
			want:     "AB000000014CD\nAB000000028CD\nAB000000031CD\n",
		},
		{
			name:     "should handle reversed range",
			letras1:  "AB",
			numeros1: "00000003",
			numeros2: "00000001",
			letras2:  "CD",
			want:     "AB000000014CD\nAB000000028CD\nAB000000031CD\n",
		},
		{
			name:     "should handle empty or invalid inputs",
			letras1:  "AB",
			numeros1: "",
			numeros2: "00000001",
			letras2:  "CD",
			want:     "",
		},
		{
			name:     "should handle invalid number format",
			letras1:  "AB",
			numeros1: "123",
			numeros2: "00000001",
			letras2:  "CD",
			want:     "",
		},
		{
			name:     "should convert letters to uppercase",
			letras1:  "ab",
			numeros1: "00000001",
			numeros2: "",
			letras2:  "cd",
			want:     "AB000000014CD\n",
		},
		{
			name:     "should handle missing letras2",
			letras1:  "AB",
			numeros1: "00000001",
			numeros2: "00000001",
			letras2:  "",
			want:     "AB000000014\n",
		},
		{
			name:     "should handle nil letras1",
			letras1:  "",
			numeros1: "00000001",
			numeros2: "00000001",
			letras2:  "",
			want:     "000000014\n",
		},
	}

	for _, tt := range testCases {
		t.Run(tt.name, func(t *testing.T) {
			got := Sequencia(tt.letras1, tt.numeros1, tt.numeros2, tt.letras2)
			if got != tt.want {
				t.Errorf("Sequencia() = %q, want %q", got, tt.want)
			}
		})
	}
}

func TestSequenciaRangeLimit(t *testing.T) {
	result := Sequencia("AB", "00000001", "00000100", "CD")
	lineCount := strings.Count(result, "\n")
	if lineCount != 50 {
		t.Errorf("Want 50 lines, got %d", lineCount)
	}

	first := strings.Split(result, "\n")[0]
	if first != "AB000000014CD" {
		t.Errorf("First line = %q, want %q", first, "AB000000014CD")
	}

	lines := strings.Split(strings.TrimSuffix(result, "\n"), "\n")
	last := lines[len(lines)-1]
	if last != "AB000000500CD" {
		t.Errorf("Last line = %q, want %q", last, "AB000000500CD")
	}
}
