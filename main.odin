package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	read_markdown()
}

Md_Char :: enum u8 {
	Hash = '#',
}

read_markdown :: proc() {
	md_file_path := os.args[1]
	file, err := os.open(md_file_path)
	defer os.close(file)
	if err != nil {
		fmt.printf("Error opening file: %v \r\n", err)
		return
	}

	stream := os.to_stream(file)
	reader: bufio.Reader
	bufio.reader_init(&reader, stream)
	defer bufio.reader_destroy(&reader)

	sb: strings.Builder
	strings.builder_init(&sb)

	parser := create_parser(&reader, sb)

	read_from_reader(parser)

	error := os.write_entire_file("output.html", string(parser.out.buf[:]))
	if error != nil {
		fmt.printf("Error writing html file: %v \r\n", error)
	}
}

read_from_reader :: proc(parser: ^Parser) {
	for {
		line, err := bufio.reader_read_byte(parser.reader)
		if err != nil {
			if err == .EOF {
				break
			}
			fmt.printf("Error reading from stream: %v", err)
			break
		}

		read_byte(line, parser)
	}
}

read_byte :: proc(char: u8, parser: ^Parser) {
	switch Md_Char(char) {
	case .Hash:
		handle_pound(char, parser)
	case:
		return
	}
}

handle_pound :: proc(char: u8, parser: ^Parser) {
	number_of_pounds := count_pounds(parser)

	skip_lines(parser, number_of_pounds)


	line, err := bufio.reader_read_bytes(parser.reader, '\n')

	if err != nil {
		fmt.printf("Error reading line: %v", err)
		return
	}

	fmt.sbprintf(&parser.out, "<h%d>", number_of_pounds)
	strings.write_string(&parser.out, string(line[:len(line) - 1]))
	fmt.sbprintf(&parser.out, "</h%d>", number_of_pounds)

	strings.write_string(&parser.out, "\n")

	return
}

count_pounds :: proc(parser: ^Parser) -> int {
	number_of_pounds := 1
	for {
		peek, err := bufio.reader_peek(parser.reader, 1)
		if err != nil {
			fmt.printf("error: %v \r\n", err)
			break
		}

		// still a # so continue
		if Md_Char(peek[0]) == .Hash {
			number_of_pounds += 1
			continue
		}

		if peek[0] == ' ' {
			break
		}
	}
	return number_of_pounds
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
