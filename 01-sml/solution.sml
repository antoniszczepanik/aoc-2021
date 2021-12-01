(*
 * This solution was run using  SML/NJ compiler.
 * To run it pass names of files you'd like to solve.
 *
 * `sml solution.sml sample.txt input.txt`
 *
 * *)

fun readLines filename =
  let
    val ins = TextIO.openIn filename 
    fun loop ins = 
      case TextIO.inputLine ins of
        SOME line => line :: loop ins 
      | NONE      => [] 
  in 
    loop ins before TextIO.closeIn ins
  end;

fun intFromString s =
  case Int.fromString s of
    SOME i => i
  | NONE => raise Fail ("Could not convert string '" ^ s ^ "' to int")

fun sumIncreasing numbers = 
  case numbers of
      x::y::xs  => if y > x 
                   then 1 + (sumIncreasing (y::xs)) 
                   else 0 + (sumIncreasing (y::xs))
     | _        => 0

fun solve1 filename =
  let
    val input = map intFromString (readLines filename)
    val result = sumIncreasing input
  in
    print ("Solution 1 - " ^ filename ^ ": " ^ (Int.toString result) ^ "\n")
  end;


fun length l =
  case l of
    x::xs => 1 + length xs
  | _     => 0;

fun sumFirst l count =
  if count = 0
  then 0
  else case l of
         [] => 0
       | x::xs => x + (sumFirst xs (count-1));

fun getWindowSum nums windowSize =
  if (length nums) < windowSize
  then []
  else
    case nums of
      []     => []
    | x::xs  => (sumFirst nums windowSize)::(getWindowSum xs windowSize);

fun solve2 filename =
  let
    val input = map intFromString (readLines filename)
    val result = sumIncreasing (getWindowSum input 3)
  in
    print ("Solution 2 - " ^ filename ^ ": " ^ (Int.toString result) ^ "\n")
  end;


val files = CommandLine.arguments()
val _ = map solve1 files
val _ = map solve2 files
val _ = OS.Process.exit(OS.Process.success)
