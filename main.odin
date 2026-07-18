package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	read_markdown()
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
				fmt.printf("EOF reached: %v", err)
				break
			}
			fmt.printf("Error reading from stream: %v", err)
			break
		}

		read_byte(line, parser)
	}
}

read_byte :: proc(char: u8, parser: ^Parser) {
	switch MD_Processor(char) {
	case .Hash:
		handle_pound(char, parser)
	case .Newline:
		strings.write_string(&parser.out, "\n")
	case:
		return
	}
}

handle_pound :: proc(char: u8, parser: ^Parser) {
	number_of_pounds, ok := count_pounds(parser)
	if !ok {
		return
	}

	line, err := bufio.reader_read_bytes(parser.reader, '\n')

	if err != nil {
		fmt.printf("Error reading line: %v", err)
		return
	}

	if number_of_pounds > HEADER_TAG_CAP {
		for _ in 0 ..< number_of_pounds {
			fmt.sbprintf(&parser.out, "#")
		}
		strings.write_string(&parser.out, string(line[:len(line) - 1]))
		return
	}


	fmt.sbprintf(&parser.out, "<h%d>", number_of_pounds)
	strings.write_string(&parser.out, string(line[:len(line) - 1]))
	fmt.sbprintf(&parser.out, "</h%d>", number_of_pounds)

	strings.write_string(&parser.out, "\n")

	return
}

count_pounds :: proc(parser: ^Parser) -> (int, bool) {
	slice_until_delim, err := bufio.reader_read_slice(parser.reader, ' ')
	if err != nil {
		fmt.printf("error: %v \r\n", err)
		return 0, false
	}
	return len(slice_until_delim), true
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
