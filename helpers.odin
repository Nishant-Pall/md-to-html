package main

import "core:bufio"
import "core:strings"

HEADER_TAG_CAP :: 6
MD_Processor :: enum u8 {
	Hash    = '#',
	Newline = '\n',
}

skip_lines :: proc(parser: ^Parser, n_to_skip: int) {
	i := 0
	for i < n_to_skip {
		bufio.reader_read_byte(parser.reader)
		i += 1
	}
}

byte_to_string_allocated :: proc(b: u8) -> string {
	single_byte_slice := []u8{b}
	return strings.clone_from_bytes(single_byte_slice)
}
