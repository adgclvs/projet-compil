
(* The type of tokens. *)

type token = 
  | Y
  | X
  | TO
  | TAIL
  | SUB
  | STEP
  | SIN
  | SET
  | SEMICOLON
  | R_SQ_BRK
  | R_PAR
  | R_CUR_BRK
  | RED
  | REAL_TYP
  | REAL_OF_INT
  | REAL of (float)
  | PRINT
  | PIXEL
  | PI
  | OR
  | OPEN
  | NOT
  | NEQ
  | MUL
  | MOD
  | L_SQ_BRK
  | L_PAR
  | L_CUR_BRK
  | LT
  | LIST
  | LEQ
  | INT_TYP
  | INT of (int)
  | IN
  | IF
  | ID of (string)
  | HEAD
  | GT
  | GREEN
  | GEQ
  | FROM
  | FOREACH
  | FOR
  | FLOOR
  | EQ
  | EOF
  | ELSE
  | DRAW
  | DOT
  | DIV
  | COS
  | COORD
  | CONS
  | COMMA
  | COLOR
  | COLON
  | CLOSE
  | BOOL_TYP
  | BOOL of (bool)
  | BLUE
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.program)

module MenhirInterpreter : sig
  
  (* The incremental API. *)
  
  include MenhirLib.IncrementalEngine.INCREMENTAL_ENGINE
    with type token = token
  
  (* The indexed type of terminal symbols. *)
  
  type _ terminal = 
    | T_error : unit terminal
    | T_Y : unit terminal
    | T_X : unit terminal
    | T_TO : unit terminal
    | T_TAIL : unit terminal
    | T_SUB : unit terminal
    | T_STEP : unit terminal
    | T_SIN : unit terminal
    | T_SET : unit terminal
    | T_SEMICOLON : unit terminal
    | T_R_SQ_BRK : unit terminal
    | T_R_PAR : unit terminal
    | T_R_CUR_BRK : unit terminal
    | T_RED : unit terminal
    | T_REAL_TYP : unit terminal
    | T_REAL_OF_INT : unit terminal
    | T_REAL : (float) terminal
    | T_PRINT : unit terminal
    | T_PIXEL : unit terminal
    | T_PI : unit terminal
    | T_OR : unit terminal
    | T_OPEN : unit terminal
    | T_NOT : unit terminal
    | T_NEQ : unit terminal
    | T_MUL : unit terminal
    | T_MOD : unit terminal
    | T_L_SQ_BRK : unit terminal
    | T_L_PAR : unit terminal
    | T_L_CUR_BRK : unit terminal
    | T_LT : unit terminal
    | T_LIST : unit terminal
    | T_LEQ : unit terminal
    | T_INT_TYP : unit terminal
    | T_INT : (int) terminal
    | T_IN : unit terminal
    | T_IF : unit terminal
    | T_ID : (string) terminal
    | T_HEAD : unit terminal
    | T_GT : unit terminal
    | T_GREEN : unit terminal
    | T_GEQ : unit terminal
    | T_FROM : unit terminal
    | T_FOREACH : unit terminal
    | T_FOR : unit terminal
    | T_FLOOR : unit terminal
    | T_EQ : unit terminal
    | T_EOF : unit terminal
    | T_ELSE : unit terminal
    | T_DRAW : unit terminal
    | T_DOT : unit terminal
    | T_DIV : unit terminal
    | T_COS : unit terminal
    | T_COORD : unit terminal
    | T_CONS : unit terminal
    | T_COMMA : unit terminal
    | T_COLOR : unit terminal
    | T_COLON : unit terminal
    | T_CLOSE : unit terminal
    | T_BOOL_TYP : unit terminal
    | T_BOOL : (bool) terminal
    | T_BLUE : unit terminal
    | T_AND : unit terminal
    | T_ADD : unit terminal
  
  (* The indexed type of nonterminal symbols. *)
  
  type _ nonterminal = 
    | N_statement_list : (Ast.statement list) nonterminal
    | N_statement : (Ast.statement) nonterminal
    | N_program : (Ast.program) nonterminal
    | N_main : (Ast.program) nonterminal
    | N_expression_list : (Ast.expression list) nonterminal
    | N_expression : (Ast.expression) nonterminal
    | N_argument_list : (Ast.argument list) nonterminal
    | N_argument : (Ast.argument) nonterminal
  
  (* The inspection API. *)
  
  include MenhirLib.IncrementalEngine.INSPECTION
    with type 'a lr1state := 'a lr1state
    with type production := production
    with type 'a terminal := 'a terminal
    with type 'a nonterminal := 'a nonterminal
    with type 'a env := 'a env
  
end

(* The entry point(s) to the incremental API. *)

module Incremental : sig
  
  val main: Lexing.position -> (Ast.program) MenhirInterpreter.checkpoint
  
end
