open Util
open Ast

(* Codez ici la passe de renommage de termes.

   Cette passe permet de simplifier grandement la gestion des passes suivantes, et de l’interprétation, en assurant qu’un nom de variable n’est jamais réutilisé dans la même portée de déclaration.

   Pour cela, on va modifier le programme en, pour chaque nom, gardant un nombre correspondant son nombre de redéfinition, et en renommant l’occurence de chaque nom par un identifiant unique (son nom, suivi de son nombre d’occurence, avec un séparateur interdit dans le langage (pour empêcher les redéfinitions)).

   Comme seule la portée des variables est importante, dans deux blocs disjoints, il est possible de réutiliser un même nom.

   Pour obtenir ce résultat, il sera nécessaire de copier les environnement avant d’évaluer des sous-blocs (puisqu’en sortant d’un bloc, il est possible de continuer à utiliser un nom défini plus haut).

   Attention, l’interpréteur ne fonctionnera pas correctement en cas de redéfinition si vous n’effectuez pas correctement cette passe.*)


let renaming_arg (argument : argument) (env : int Environment.t) = match argument with
   |Argument(id, typ, annotation) -> (match Environment.get env id with
      |Some(i) -> let j = i+1 in let _ = Environment.add env id j in Argument(id^"#"^(string_of_int j), typ, annotation)
      |None -> let _ = Environment.add env id 0 in Argument(id, typ, annotation))
;;

let rec renaming_stmt (statement : statement) (env : int Environment.t) = match statement with
   |Declaration(id, typ, annotation) -> (match Environment.get env id with
      |Some(i) -> let j = i+1 in let _ = Environment.add env id j in Declaration(id^"#"^(string_of_int j), typ, annotation)
      |None -> let _ = Environment.add env id 0 in Declaration(id, typ, annotation))
   |Block(l, annotation) -> let _ = Environment.copy env in Block(l, annotation) (*faut faire un list.fold_right sur l mais je suis nul*)
   |IfThenElse(test, th, el, annotation) -> let new_env = Environment.copy env in let new_th = renaming_stmt th new_env and new_el = renaming_stmt el new_env 
      in IfThenElse(test, new_th, new_el, annotation)
   |For(id, e1, e2, e3, body, annotation) -> let new_env = Environment.copy env in let new_body = renaming_stmt body new_env in (match Environment.get env id with 
      |Some(i) -> let j = i+1 in let _ = Environment.add env id j in For(id^"#"^(string_of_int j), e1, e2, e3, new_body, annotation)
      |None -> let _ = Environment.add env id 0 in For(id, e1, e2, e3, new_body, annotation))
   |Foreach(id, test, body, annotation) -> let new_env = Environment.copy env in let new_body = renaming_stmt body new_env in (match Environment.get env id with
      |Some(i) -> let j = i+1 in let _ = Environment.add env id j in Foreach(id^"#"^(string_of_int j), test, new_body, annotation)
      |None -> let _ = Environment.add env id 0 in Foreach(id, test, new_body, annotation))
   |_ -> statement
;;

let renaiming_expr (expression : expression) (env : int Environment.t) = match expression with
   |Variable(id, annotation) -> (match Environment.get env id with
      |Some(i) -> let j = i+1 in let _ = Environment.add env id j in Variable(id^"#"^(string_of_int j), annotation)
      |None -> let _ = Environment.add env id 0 in Variable(id, annotation))
   |_ -> expression
;;

let renaming (program : program) = let name_counter = Environment.new_environment () in
  Environment.add name_counter "x" 0;
  program