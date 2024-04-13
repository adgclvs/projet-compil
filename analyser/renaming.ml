open Util
open Ast

(* Codez ici la passe de renommage de termes.

   Cette passe permet de simplifier grandement la gestion des passes suivantes, et de l’interprétation, en assurant qu’un nom de variable n’est jamais réutilisé dans la même portée de déclaration.

   Pour cela, on va modifier le programme en, pour chaque nom, gardant un nombre correspondant son nombre de redéfinition, et en renommant l’occurence de chaque nom par un identifiant unique (son nom, suivi de son nombre d’occurence, avec un séparateur interdit dans le langage (pour empêcher les redéfinitions)).

   Comme seule la portée des variables est importante, dans deux blocs disjoints, il est possible de réutiliser un même nom.

   Pour obtenir ce résultat, il sera nécessaire de copier les environnement avant d’évaluer des sous-blocs (puisqu’en sortant d’un bloc, il est possible de continuer à utiliser un nom défini plus haut).

   Attention, l’interpréteur ne fonctionnera pas correctement en cas de redéfinition si vous n’effectuez pas correctement cette passe.*)

let renaming_arg (argument : argument) (env : 'a Environment.t) = match argument with
   |Argument(id, typ, annotation) -> (match Environment.get env id with
      |Some(i) -> let j = i+1 in let _ = Environment.modify env id j in (Argument(id^"#"^(string_of_int j), typ, annotation))
      |None -> let _ = Environment.add env id 0 in (Argument(id, typ, annotation)))
;;

let rec renaming_arg_list (argument_list : argument list) (env : 'a Environment.t) = match argument_list with
   |[] -> []
   |arg::arg_list -> (renaming_arg arg env) ::(renaming_arg_list arg_list env)
;;

let rec renaming_expr (expression : expression) (env : 'a Environment.t) = match expression with
   |Const_int(i, annotation) -> Const_int(i, annotation)
   |Const_real(r, annotation) -> Const_real(r, annotation)
   |Const_bool(b, annotation) -> Const_bool(b, annotation)
   |Variable(id, annotation) -> (match Environment.get env id with
      |Some(i) -> if i = 0 then Variable(id, annotation) else Variable(id^"#"^(string_of_int i), annotation)
      |None -> let _ = Environment.add env id 0 in Variable(id, annotation))
   |Coord(e1, e2, annotation) -> Coord((renaming_expr e1 env), (renaming_expr e2 env), annotation)
   |Color(e1, e2, e3, annotation) -> Color((renaming_expr e1 env), (renaming_expr e2 env), (renaming_expr e3 env), annotation)
   |Pixel(e1, e2, annotation) -> Pixel((renaming_expr e1 env), (renaming_expr e2 env), annotation)
   |Binary_operator(op, e1, e2, annotation) -> Binary_operator(op, (renaming_expr e1 env), (renaming_expr e2 env), annotation)
   |Unary_operator(op, e, annotation) -> Unary_operator(op, (renaming_expr e env), annotation)
   |Field_accessor(field, expr, annotation) -> Field_accessor(field, (renaming_expr expr env), annotation)
   |List(expr_list, annotation) -> List(List.map (fun x -> renaming_expr x env) expr_list, annotation)
   |Append(e1, e2, annotation) -> Append((renaming_expr e1 env), (renaming_expr e2 env), annotation)
;;

let rec renaming_stmt (statement : statement) (env : 'a Environment.t) = match statement with
   |Affectation(e1, e2, annotation) -> Affectation((renaming_expr e1 env), (renaming_expr e2 env), annotation)
   |Declaration(id, typ, annotation) -> (match Environment.get env id with
      |Some(i) -> let j = i+1 in let _ = Environment.modify env id j in Declaration(id^"#"^(string_of_int j), typ, annotation)
      |None -> let _ = Environment.add env id 0 in Declaration(id, typ, annotation))
   |Block(l, annotation) -> let new_env = Environment.copy env in let new_l = List.map (fun x -> renaming_stmt x new_env) l in Block(new_l, annotation) 
   |IfThenElse(test, th, el, annotation) -> let new_th_env = Environment.copy env in let new_el_env = Environment.copy env in 
      let new_th = renaming_stmt th new_th_env in let new_el = renaming_stmt el new_el_env 
      in IfThenElse((renaming_expr test env), new_th, new_el, annotation)
   |For(id, e1, e2, e3, body, annotation) -> let new_env = Environment.copy env in (match Environment.get env id with 
      |Some(i) -> let j = i+1 in let _ = Environment.modify new_env id j in let new_body = renaming_stmt body new_env 
         in For(id^"#"^(string_of_int j), (renaming_expr e1 env), (renaming_expr e2 env), (renaming_expr e3 env), new_body, annotation)
      |None -> let _ = Environment.add new_env id 0 in let new_body = renaming_stmt body new_env in
         For(id, (renaming_expr e1 env), (renaming_expr e2 env), (renaming_expr e3 env), new_body, annotation))
   |Foreach(id, test, body, annotation) -> let new_env = Environment.copy env in (match Environment.get env id with
      |Some(i) -> let j = i+1 in let _ = Environment.modify new_env id j in let new_body = renaming_stmt body new_env in 
         Foreach(id^"#"^(string_of_int j), (renaming_expr test env), new_body, annotation)
      |None -> let _ = Environment.add new_env id 0 in let new_body = renaming_stmt body new_env in 
         Foreach(id, (renaming_expr test env), new_body, annotation))
   |Draw_pixel(expr, annotation) -> Draw_pixel((renaming_expr expr env), annotation)
   |Print(expr, annotation) -> Print((renaming_expr expr env), annotation)
   |Nop -> Nop
;;

let renaming (program : program) = let name_counter = Environment.new_environment () in match program with
   |Program(arg_list, stmt) -> let arg_list = renaming_arg_list arg_list name_counter in let stmt = renaming_stmt stmt name_counter in 
      Program(arg_list, stmt)
;;
 (* Environment.add name_counter "x" 0;
  program*)