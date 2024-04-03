%{
    open Ast

    (*Le parseur doit générer des Ast.program.
    Pour les annotation, il vous suffit de créer l’annotation avec [Annotation.create $loc] qui sera ce qu’il vous faut dans tous les cas : $loc est un paramètre qui correspond aux positions délimitant la chaîne de caractères parsée par la règle où il est utilisé, ce qui est exactement ce qu’il faut mettre dans l’annotation.*)
%}

%token AND        
%token BLUE       
%token BOOL_TYP   
%token COLOR      
%token COORD      
%token COS        
%token DRAW       
%token ELSE       
%token FLOOR      
%token FOR        
%token FOREACH    
%token FROM       
%token GREEN      
%token HEAD       
%token IF         
%token IN         
%token INT_TYP    
%token LIST       
%token NOT        
%token OR         
%token PIXEL      
%token PRINT      
%token REAL_TYP   
%token REAL_OF_INT
%token RED        
%token SET        
%token SIN        
%token STEP       
%token TAIL       
%token TO         
%token Y          
%token X          
%token PI         
%token OPEN       
%token CLOSE      
%token ADD        
%token SUB        
%token MUL        
%token DIV        
%token MOD        
%token EQ         
%token NEQ        
%token LEQ        
%token GEQ        
%token LT         
%token GT         
%token COLON      
%token CONS       
%token DOT        
%token L_PAR      
%token R_PAR      
%token L_SQ_BRK   
%token R_SQ_BRK  
%token L_CUR_BRK
%token R_CUR_BRK
%token COMMA      
%token SEMICOLON
%token <string> ID
%token <int> INT
%token <float> REAL
%token <bool> BOOL
%token EOF



%start <program> main
%%

main:
| p = program EOF { Program([],Block([],Annotation.create $loc)) }


program:
| LT arg_list = argument_list GT stmt = statement  { Program(arg_list, stmt)}
| stmt = statement      { Program([], stmt)}


argument_list:
| {()} //TODO

statement:
| {()}  // TODO

expression:
| i = INT   { Const_int(i, Annotation.create $loc)}
| r = REAL  { Const_real(r, Annotation.create $loc)}
| pi = PI   { Const_real(Float.pi, Annotation.create $loc)}
| b = BOOL  { Const_bool(b, Annotation.create $loc)}
| id = ID   { Variable(id, Annotation.create $loc)}
| COORD L_PAR expr1 = expression COMMA expr2 = expression R_PAR { Coord(expr1, expr2, Annotation.create $loc)}
| COLOR L_PAR expr1 = expression COMMA expr2 = expression COMMA expr3 = expression R_PAR { Color(expr1, expr2, expr3, Annotation.create $loc)}
| PIXEL L_PAR expr1 = expression COMMA expr2 = expression R_PAR { Pixel(expr1, expr2, Annotation.create $loc)}
| expr1 = expression b = binop expr2 = expression  { Binary_operator(b, expr1, expr2, Annotation.create $loc)}
| u = unop expr = expression { Unary_operator(u, expr, Annotation.create $loc)}
| expr = expression DOT f = field { Field_accessor(f, expr, Annotation.create $loc)}
| expr1 = expression CONS expr2 = expression  { Append(expr1, expr2, Annotation.create $loc)}
| L_PAR expr = expression R_PAR     { expr }
//faire List([expr1,..., exprk])


%inline binop:
| ADD   { Add }
| SUB   { Sub }
| MUL   { Mul }
| DIV   { Div }
| MOD   { Mod }
| AND   { And }
| OR    { Or }
| EQ    { Eq }
| NEQ   { Neq }
| LT    { Lt }
| GT    { Gt }
| LEQ   { Leq }
| GEQ   { Geq }

%inline unop:
| SUB           { Opposite } 
| NOT           { Not }
| HEAD          { Head }
| TAIL          { Tail }
| FLOOR         { Floor }
| REAL_OF_INT   { Real_of_int }
| COS           { Cos }   
| SIN           { Sin }

%inline field:
| COLOR     { Color_field }
| COORD     { Coord_field }
| X         { X_field }
| Y         { Y_field }
| BLUE      { Blue_field }
| RED       { Red_field }
| GREEN     { Green_field }