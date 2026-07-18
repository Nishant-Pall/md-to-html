package main

import "core:bufio"
import "core:strings"

Parser :: struct {
	reader: ^bufio.Reader,
	out:    strings.Builder,
}

create_parser :: proc(reader: ^bufio.Reader, sb: strings.Builder) -> ^Parser {
	parser := new(Parser)
	parser.reader = reader
	parser.out = sb
	return parser
}
