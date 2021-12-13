import os
import std/[strscans, strutils, strformat]
import tables

type
  Node = ref object
    name: string
    adj: seq[string] # sequence of names
    is_small: bool
    times_visited: int


proc read_graph(file_path: string): Table[string, Node] =
  var nodes = initTable[string, Node]()
  proc get_or_create_node(name: string): Node =
      if not (name in nodes):
        nodes[name] = Node(
          name: name,
          is_small: not isUpperAscii(name[0]),
          times_visited: 0,
          )
      return nodes[name]

  for l in lines file_path:
    var src, dst: string
    if scanf(l, "$w-$w", src, dst):
      var dst_n = get_or_create_node(dst)
      var src_n = get_or_create_node(src)
      src_n.adj.add(dst)
      dst_n.adj.add(src)

  return nodes

proc count_paths(src: string, nodes: Table[string, Node], max_visits: int = 1): int =
  if src == "end":
    return 1

  var c = 0
  nodes[src].times_visited += 1
  # small vertex visited twice => allow visiting small vertices only once
  var new_max_visits = max_visits
  if (src != "start") and (nodes[src].is_small) and (nodes[src].times_visited == 2):
    new_max_visits = 1

  for dst in nodes[src].adj:
    # ignore vertices over the limit
    if nodes[dst].is_small and (nodes[dst].times_visited >= new_max_visits):
      continue
    c += count_paths(dst, nodes, new_max_visits, p & "," & dst)

  # clean-up nodes
  nodes[src].times_visited -= 1
  return c

proc solution1(nodes: Table[string, Node]): int =
  return count_paths("start", nodes)

proc solution2(nodes: Table[string, Node]): int =
  nodes["start"].times_visited = 1
  return count_paths("start", nodes, 2)

when isMainModule:
  if paramCount() < 1:
    stderr.writeLine("Provide path of a file you'd like to solve")
    quit(1)

  var nodes = read_graph(paramStr(1))
  echo "Day 12:"
  echo(fmt"Solution 1: {solution1(nodes)}")
  echo(fmt"Solution 2: {solution2(nodes)}")
