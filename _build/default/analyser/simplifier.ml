(* Codez ici le simplificateur de termes.

    Tout comme pour le langage du cours, l’idée consiste à remplacer les termes constants par le résultat de leur calcul.

    Faites une sous-fonctions récursive pour les expressions et les statements.
    Ces fonction font un pattern matching sur leur argument et traitent chaque cas séparément. Elles renvoient un argument de même type que celui reçu.
    Par exemple : simplify_expression : Ast.expression -> Ast.expression

    Les cas minimaux attendus sont les cas sur les entiers, les flottants, les booléens, ainsi que les if dont le test est constant, et les for qui ne s’exécutent jamais.

    Deux points (entre autres) qui peuvent vous permettre d’aller plus loin :
      - les expressions ne peuvent pas faire d’effet de bord ici, ce qui permet de simplifier des expressions pas nécessairement constantes.
      - Les types composés (pixels, coordonnées et couleurs) peuvent également être simplifiés (e.g., (1,2) + (2,x) peut être simplifié en (3,2+x)).

    Vous détaillerez dans le rapport les différents cas que vous simplifiez dans votre simplificateur.
*)
open Ast

let rec simplifier_expr (expr : Ast.expression) =
  match expr with
  | Const_int _ -> expr
  | Const_real _ -> expr
  | Const_bool _ -> expr
  | Variable _ -> expr
  | Coord (x, y, annotation) ->
      Coord (simplifier_expr x, simplifier_expr y, annotation)
  | Color (r, g, b, annotation) ->
      Color
        ( simplifier_expr r,
        simplifier_expr g,
          simplifier_expr b,
          annotation )
  | Pixel (coord, color, annotation) ->
      Pixel (simplifier_expr coord, simplifier_expr color, annotation)
      | Unary_operator (op, e, annotation) -> (
        match e with
        | Unary_operator (Real_of_int, Const_int (n, _), _) when op = Floor ->
            Const_int (n, annotation)
        | _ -> (
            match simplifier_expr e with
            | Const_int (i, _) -> (
                match op with
                | Opposite -> Const_int (-i, annotation)
                | Real_of_int -> Const_real (float_of_int i, annotation)
                | _ -> Unary_operator (op, simplifier_expr e, annotation))
            | Const_real (r, _) -> (
                match op with
                | Opposite -> Const_real (-.r, annotation)
                | Floor -> Const_int (int_of_float r, annotation)
                | Cos -> Const_real (Float.cos r, annotation)
                | Sin -> Const_real (Float.sin r, annotation)
                | _ -> Unary_operator (op, simplifier_expr e, annotation))
            | Const_bool (b, _) -> (
                match op with
                | Not -> Const_bool (not b, annotation)
                | _ -> Unary_operator (op, simplifier_expr e, annotation))
            | List (l, _) ->
                List (List.map (fun e -> simplifier_expr e) l, annotation)
            | _ -> Unary_operator (op, simplifier_expr e, annotation)))
  | Binary_operator (op, e1, e2, annotation) ->
      (match (simplifier_expr e1, simplifier_expr e2) with
      | (Const_int (i1, _), Const_int (i2, _)) ->
          (match op with
          | Plus -> Const_int (i1 + i2, annotation)
          | Minus -> Const_int (i1 - i2, annotation)
          | Times -> Const_int (i1 * i2, annotation)
          | Div -> Const_int (i1 / i2, annotation)
          | Rem -> Const_int (i1 mod i2, annotation)
          | Equal -> Const_bool (i1 = i2, annotation)
          | Diff -> Const_bool (i1 <> i2, annotation)
          | Lt -> Const_bool (i1 < i2, annotation)
          | Gt -> Const_bool (i1 > i2, annotation)
          | Leq -> Const_bool (i1 <= i2, annotation)
          | Geq -> Const_bool (i1 >= i2, annotation)
          | _ -> Binary_operator (op, simplifier_expr e1, simplifier_expr e2, annotation))
      | (Const_real (r1, _), Const_real (r2, _)) ->
          (match op with
          | Plus -> Const_real (r1 +. r2, annotation)
          | Minus -> Const_real (r1 -. r2, annotation)
          | Times -> Const_real (r1 *. r2, annotation)
          | Div -> Const_real (r1 /. r2, annotation)
          | Rem -> Const_real (mod_float r1 r2, annotation)
          | Equal -> Const_bool (r1 = r2, annotation)
          | Diff -> Const_bool (r1 <> r2, annotation)
          | Lt -> Const_bool (r1 < r2, annotation)
          | Gt -> Const_bool (r1 > r2, annotation)
          | Leq -> Const_bool (r1 <= r2, annotation)
          | Geq -> Const_bool (r1 >= r2, annotation)
          | _ -> Binary_operator (op, simplifier_expr e1, simplifier_expr e2, annotation))
      | (Const_bool (b1, _), Const_bool (b2, _)) ->
          (match op with
          | Equal -> Const_bool (b1 = b2, annotation)
          | Diff -> Const_bool (b1 <> b2, annotation)
          | Lt -> Const_bool (b1 < b2, annotation)
          | Gt -> Const_bool (b1 > b2, annotation)
          | Leq -> Const_bool (b1 <= b2, annotation)
          | Geq -> Const_bool (b1 >= b2, annotation)
          | And -> Const_bool (b1 && b2, annotation)
          | Or -> Const_bool (b1 || b2, annotation)
          | _ -> Binary_operator (op, simplifier_expr e1, simplifier_expr e2, annotation))
      | (Coord (x, y, _), Const_int (i, _)) ->
          Coord
            (simplifier_expr (Binary_operator (op, x, Const_int (i, annotation), annotation)),
            simplifier_expr (Binary_operator (op, y, Const_int (i, annotation), annotation)),
            annotation)
      | (Const_int (i, _), Coord (x, y, _)) ->
          Coord
            (simplifier_expr (Binary_operator (op, Const_int (i, annotation), x, annotation)),
            simplifier_expr (Binary_operator (op, Const_int (i, annotation), y, annotation)),
            annotation)
      | (Color (r, g, b, _), Const_int (i, _)) ->
          Color
            (simplifier_expr (Binary_operator (op, r, Const_int (i, annotation), annotation)),
            simplifier_expr (Binary_operator (op, g, Const_int (i, annotation), annotation)),
            simplifier_expr (Binary_operator (op, b, Const_int (i, annotation), annotation)),
            annotation)
      | (Const_int (i, _), Color (r, g, b, _)) ->
          Color
            (simplifier_expr (Binary_operator (op, Const_int (i, annotation), r, annotation)),
            simplifier_expr (Binary_operator (op, Const_int (i, annotation), g, annotation)),
            simplifier_expr (Binary_operator (op, Const_int (i, annotation), b, annotation)),
            annotation)
      | (Pixel (coord1, color1, _), Pixel (coord2, color2, _)) ->
          Pixel
            (simplifier_expr (Binary_operator (op, coord1, coord2, annotation)),
            simplifier_expr (Binary_operator (op, color1, color2, annotation)),
            annotation)
      | (List (l1, _), List (l2, _)) ->
          (match op with
          | Plus -> List (l1 @ l2, annotation)
          | _ -> Binary_operator (op, simplifier_expr e1, simplifier_expr e2, annotation))
      | _ -> Binary_operator (op, simplifier_expr e1, simplifier_expr e2, annotation))
  | Field_accessor (field, e, annotation) -> (
      match simplifier_expr e with
      | Pixel (coord, color, _) -> (
          match field with
          | Color_field -> simplifier_expr color
          | Coord_field -> simplifier_expr coord
          | _ -> Field_accessor (field, simplifier_expr e, annotation))
      | Coord (x, y, _) -> (
          match field with
          | X_field -> simplifier_expr x
          | Y_field -> simplifier_expr y
          | _ -> Field_accessor (field, simplifier_expr e, annotation))
      | Color (r, g, b, _) -> (
          match field with
          | Red_field -> simplifier_expr r
          | Green_field -> simplifier_expr g
          | Blue_field -> simplifier_expr b
          | _ -> Field_accessor (field, simplifier_expr e, annotation))
      | _ -> Field_accessor (field, simplifier_expr e, annotation))
  | Append (e, l, annotation) -> (
      match simplifier_expr l with
      | List (list, _) -> List (simplifier_expr e :: list, annotation)
      | _ -> Append (simplifier_expr e, simplifier_expr l, annotation))
  | _ -> expr

let rec simplifier_statement (statement : Ast.statement) =
  match statement with
  | Affectation (var, expr, annotation) ->
      Affectation (var, simplifier_expr expr, annotation)
  | Block (l, annotation) ->
      Block (List.map (fun s -> simplifier_statement s) l, annotation)
  | IfThenElse (test, i_then, i_else, annotation) -> (
      let simplifier_test = simplifier_expr test in
      match simplifier_test with
      | Const_bool (true, _) -> simplifier_statement i_then
      | Const_bool (false, _) -> simplifier_statement i_else
      | _ -> IfThenElse (simplifier_test, i_then, i_else, annotation))
  | For (name, init, target, increment, body, annotation) -> (
      let simplifier_init = simplifier_expr init in
      let simplifier_target = simplifier_expr target in
      let simplifier_increment = simplifier_expr increment in
      match (simplifier_init, simplifier_target) with
      | Const_int (start, _), Const_int (end_, _) ->
          if start > end_ then Block ([], annotation)
          else
            For
              ( name,
                simplifier_init,
                simplifier_target,
                simplifier_increment,
                simplifier_statement body,
                annotation )
      | _ ->
          For
            ( name,
              simplifier_init,
              simplifier_target,
              simplifier_increment,
              simplifier_statement body,
              annotation ))
  | Foreach (name, list, body, annotation) -> (
      let simplified_list = simplifier_expr list in
      match simplified_list with
      | List (l, _) -> (
          match l with
          | [] -> Block ([], annotation)
          | _ -> Foreach (name, simplified_list, body, annotation))
      | _ -> Foreach (name, simplified_list, body, annotation))
  | Draw_pixel (expr, annotation) ->
      Draw_pixel (simplifier_expr expr, annotation)
  | Print (expr, annotation) -> Print (simplifier_expr expr, annotation)
  | _ -> statement

let simplifier (program : Ast.program) =
  match program with
  | Program (arg_list, statement) ->
      Program (arg_list, simplifier_statement statement)