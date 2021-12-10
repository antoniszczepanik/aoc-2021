let readlines filename = 
    let lines = ref [] in
    let chan = open_in filename in
    try
      while true; do
        lines := input_line chan :: !lines
      done; !lines
    with End_of_file ->
      close_in chan;
      List.rev !lines ;;

let explode str =
  let rec exp a b =
    if a < 0 then b
    else exp (a - 1) (str.[a] :: b)
  in
  exp (String.length str - 1) []

let matches symbol other =
    match symbol with
    | ')' -> other = '('
    | ']' -> other = '['
    | '}' -> other = '{'
    | '>' -> other = '<'
    | _   -> raise (Invalid_argument "unknown symbol")

let isOpening symbol = 
    match symbol with
    | '(' | '[' | '{' | '<' -> true
    | _                     -> false

let solution1 lines =
    let rec getCorrupted input stack = 
        let consume symbol syms stack =
            if isOpening symbol
            then getCorrupted syms (symbol::stack)
            else match stack with
                | top::rest -> if matches symbol top
                               then getCorrupted syms rest
                               else symbol
                | _ -> ' '
        in
        match input with
        | symbol::syms -> 
                if isOpening symbol
                then getCorrupted syms (symbol::stack)
                else consume symbol syms stack
        | _ -> ' '
    in

    let rec getPoints line = 
        let chars = explode line in
        match (getCorrupted chars []) with
        | ' ' -> 0 (* symbol to denote incomplete/matching lines *)
        | ')' -> 3
        | ']' -> 57
        | '}' -> 1197
        | '>' -> 25137
        | other   -> raise (Invalid_argument "unexpected corrupted char")
    in

    let rec getScore lines = 
        match lines with
        | l :: ls -> (getPoints l) + getScore ls
        | _    -> 0
    in
    getScore lines

let get_match symbol =
    match symbol with
    | '(' -> ')'
    | '[' -> ']'
    | '{' -> '}'
    | '<' -> '>'
    | _   -> raise (Invalid_argument "unknown symbol")


let solution2 lines = 
    let rec getMatchesForStack stack =
        match stack with
        | top::rest -> (get_match top)::getMatchesForStack(rest)
        | []        -> []
    in

    let rec getMatches input stack = 
        let consume symbol syms stack =
            if isOpening symbol
            then getMatches syms (symbol::stack)
            else match stack with
                | top::rest -> if matches symbol top
                               then getMatches syms rest
                               else []
                | [] -> []
        in
        match input with
        | symbol::syms -> 
                if isOpening symbol
                then getMatches syms (symbol::stack)
                else consume symbol syms stack
        | [] -> getMatchesForStack stack
    in

    let getPoint chr =
        match chr with
        | ')' -> 1
        | ']' -> 2
        | '}' -> 3
        | '>' -> 4
        | _   -> raise (Invalid_argument "unknown symbol")
    in

    let getScore chars =
        let rec getScoreInner acc chars =
            match chars with
            | x::xs -> getScoreInner ((acc * 5) + (getPoint x)) xs
            | []    -> acc
        in
        let matches = getMatches chars [] in
        getScoreInner 0 matches
    in

    let scoresSorted = lines
        |> List.map explode
        |> List.map getScore
        |> List.filter (fun x -> x > 0)
        |> List.sort (fun x y -> x - y)
    in
    List.nth scoresSorted ((List.length scoresSorted)/2)

let run =
  let filepath = List.hd (List.tl (Array.to_list Sys.argv)) in
  let lines = readlines filepath in
  Printf.printf "Day 10:\n";
  Printf.printf "Solution 1: %d\n" (solution1 lines);
  Printf.printf "Solution 2: %d\n" (solution2 lines);
