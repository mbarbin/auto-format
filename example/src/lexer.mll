{
}

let white = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let ident = (alpha | '_') (alpha | digit | '_' | '-')*

rule read = parse
  | white    { read lexbuf }
  | newline  { Lexing.new_line lexbuf; read lexbuf }
  | '#' ([^ '\r' '\n']* as c) { Parser.COMMENT c }
  | '='      { Parser.EQUALS }
  | "true"   { Parser.BOOL true }
  | "false"  { Parser.BOOL false }
  | digit+ as n { Parser.INT (int_of_string n) }
  | '"' ([^ '"' '\n']* as s) '"' { Parser.STRING s }
  | ident as id { Parser.KEY id }
  | eof      { Parser.EOF }
  | _ as c   { failwith (Printf.sprintf "Unexpected character: %c" c) }
