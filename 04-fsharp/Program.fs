open System
open System.IO

type Value = {
    v:      int
    marked: int
}
type Row   = Value list
type Board = Row list


let readLines (fileName: string): string list =
    let fileContent = File.ReadAllText(fileName)
    fileContent.Split("\n") |> Array.toList

let readSequence (fileName: string): int list =
    let firstLine = (readLines fileName).Head
    firstLine.Split(",") |> Array.toList |> List.map System.Int32.Parse

let readBoards (fileName: string): Board list =
    let readRow (line: string): Row =
        let row = line.Split(" ") |> Array.toList |> List.filter (fun (el: string) -> (el.Length > 0)) |> List.map System.Int32.Parse
        List.map (fun e -> {v=e; marked=0}) row

    let addRow (oldBoard: Board) (row: Row): Board =
        oldBoard @ [row];

    let addRowToNewestBoard (boards: Board list) (row: Row): Board list =
        match boards with
        | []    -> [[row]]
        | x::xs -> (addRow x row)::xs

    let rec readBoardsInner (boards: Board list) (lines: string list): Board list =
        match lines with
        | []         -> boards
        | line::[]   -> if (line.Length > 1) then addRowToNewestBoard boards (readRow line)
                        else boards
        | line::line2::rest -> if (line.Length > 1)
                               then readBoardsInner (addRowToNewestBoard boards (readRow line)) (line2::rest)
                               else readBoardsInner ([readRow line2]::boards) rest
    readBoardsInner [] (readLines fileName).Tail.Tail // Skip first two lines.

let isWin (board: Board): bool =
    let getRowMarks (row: Row): int list = List.map (fun r -> r.marked) row
    let getBoardMarks (board: Board) = List.map getRowMarks board
    let rec sumMarkedValueLists (a: int list) (b: int list): int list =
        match a, b with
        | [], []             -> []
        | a::atail, b::btail -> (a + b) :: (sumMarkedValueLists atail btail)
        | a::atail, []       -> failwith "length of lists to sum is uneven"
        | [], b::btail       -> failwith "length of lists to sum is uneven"

    let rec getRowsSum (bMarks: int list list): int list =
        match bMarks with
        | []               -> []
        | row::[]          -> row
        | row1::row2::rows -> getRowsSum ((sumMarkedValueLists row1 row2)::rows)

    let rec getColumnsSum (bMarks: int list list): int list =
        match bMarks with
        | []    -> []
        | x::xs -> (List.sum x)::(getColumnsSum xs)

    let rec checkSums (sums: int list): bool =
        match sums with
        | []    -> false
        | x::xs -> if (x >= 5) then true else checkSums xs

    let boardMarks = getBoardMarks board
    checkSums (getRowsSum boardMarks) || checkSums (getColumnsSum boardMarks)


let rec findWin (boards: Board list): Board option =
    match boards with
    | []    -> None
    | x::xs -> if isWin(x) then Some(x) else findWin(xs)

let markNumberIfExists (number: int) (board: Board): Board =
    let rec markNumberInRow (number: int) (row: Row) : Row =
        match row with
        | []    -> []
        | x::xs -> if x.v = number
                   then {v=x.v; marked=1}::xs
                   else x::(markNumberInRow number xs)
    List.map (markNumberInRow number) board

let rec markNumbers (boards: Board list) (number: int): Board list =
    match boards with
    | []    -> []
    | b::bs -> (markNumberIfExists number b)::(markNumbers bs number)

let getScore (winningBoard: Board) (winningSeqNumber: int): int =
    let rec sumUnmarkedValues (row: Row): int =
        match row with
        | []    -> 0
        | x::xs -> if x.marked = 0
                   then x.v + sumUnmarkedValues xs
                   else sumUnmarkedValues xs
    let rec getBoardSum (b: Board): int =
        match b with
        | []        -> 0
        | row::rows -> (sumUnmarkedValues row) + (getBoardSum rows)
    let sum = getBoardSum winningBoard
    sum * winningSeqNumber

let rec play (sequence: int list) (boards: Board list): int =
    match sequence with
    | []    -> failwith "sequence ended with no winning board"
    | x::[] ->
        let markedBoards = markNumbers boards x
        getScore markedBoards.[0] x
    | x::xs ->
        let markedBoards = markNumbers boards x
        let winningBoard = findWin markedBoards
        match winningBoard with
        | Some(winningBoard) -> getScore winningBoard x
        | None               -> play xs markedBoards

let solution1 fileName =
    let sequence: int list = readSequence fileName
    let boards: Board list = readBoards   fileName
    play sequence boards

let solution2 fileName =
    let sequence: int list = readSequence fileName
    let boards: Board list = readBoards   fileName
    let rec getScoreOfLastWinningBoard (sequence: int list) (boards: Board list): int=
        match sequence with
        | []    -> failwith "sequence ended with more than one board left"
        | x::xs ->
            let markedBoards = markNumbers boards x
            let remainingBoards =
                List.filter (fun b -> not (isWin b) && (List.length b) > 1) markedBoards
            if (List.length remainingBoards) = 1
            then play xs remainingBoards
            else getScoreOfLastWinningBoard xs remainingBoards

    getScoreOfLastWinningBoard sequence boards

[<EntryPoint>]
let main argv =
    printfn "Day 3:"
    printfn "Solution 1: %d" (solution1 argv.[0])
    printfn "Solution 2: %d" (solution2 argv.[0])
    0
