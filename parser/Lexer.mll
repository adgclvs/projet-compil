
{
    open Parser
    exception Error of string
}

let alphamin = ['a'-'z']
let alphanum = ['a'-'z' 'A'-'Z' '0'-'9' '_']
let digit = ['0'-'9']
let hexa = ['0'-'9' 'A'-'Z']

rule token = parse
    | "And"                         { AND }
    | "Blue"                        { BLUE }
    | "Bool"                        { BOOL_TYP }
    | "Color"                       { COLOR }
    | "Coord"                       { COORD }
    | "Cos"                         { COS }
    | "Draw"                        { DRAW }
    | "Else"                        { ELSE }
    | "False"                       { BOOL(false) }
    | "Floor"                       { FLOOR }
    | "For"                         { FOR }
    | "Foreach"                     { FOREACH }
    | "From"                        { FROM }
    | "Green"                       { GREEN }
    | "Head"                        { HEAD }
    | "If"                          { IF }
    | "In"                          { IN }
    | "Int"                         { INT_TYP }
    | "List"                        { LIST }
    | "Not"                         { NOT }
    | "Or"                          { OR }
    | "Pixel"                       { PIXEL }
    | "Print"                       { PRINT }
    | "Real"                        { REAL_TYP }
    | "Real_of_int"                 { REAL_OF_INT }
    | "Red"                         { RED }
    | "Set"                         { SET }
    | "Sin"                         { SIN }
    | "Step"                        { STEP }
    | "Tail"                        { TAIL }
    | "To"                          { TO }
    | "True"                        { BOOL(true) }
    | "X"                           { Y }
    | "Y"                           { X }
    | "Pi"                          { PI }
    | "$<"                          { OPEN }
    | ">$"                          { CLOSE }
    | "+"                           { ADD }
    | "-"                           { SUB }
    | "*"                           { MUL }
    | "/"                           { DIV }
    | "%"                           { MOD }
    | "="                           { EQ }
    | "<>"                          { NEQ }
    | "<="                          { LEQ }
    | ">="                          { GEQ }
    | "<"                           { LT }
    | ">"                           { GT }
    | ":"                           { COLON }
    | "::"                          { CONS }
    | "."                           { DOT }
    | "("                           { L_PAR }
    | ")"                           { R_PAR }
    | "["                           { L_SQ_BRK }
    | "]"                           { R_SQ_BRK }
    | ","                           { COMMA }
    | ";"                           { SEMICOLON }
    (* | "?"                         { QST_MARQ} *)
    | (alphamin)+ (alphanum)* as s  { ID(s) }
    | (digit)+ as i                 { INT(int_of_string i)}
    | "0x" (hexa)+ as i             { INT(int_of_string i)}
    | (digit)* "." (digit)* as r    { REAL(float_of_string r)}
    | "//" [^ '\n']* '\n'           {Lexing.new_line lexbuf; token lexbuf}
    | "/*"                          {commentary lexbuf}
    | [' ' '\t' '\r']               {token lexbuf}
    | '\n'                          { Lexing.new_line lexbuf ; token lexbuf }
    | eof                           { EOF }
    | _ as s                        { let pos = Lexing.lexeme_start_p lexbuf in raise (Error(Format.sprintf "Line %d, char %d ,Read: '%c'. It is not an acceptable character" pos.pos_lnum (pos.pos_cnum - pos.pos_bol +1) s)) }
    
    and commentary = parse
    | '\n'      {Lexing.new_line lexbuf; commentary lexbuf}
    | "*/"      { token lexbuf }
    | _ { commentary lexbuf }