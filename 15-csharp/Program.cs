using System.Collections.Generic;
using System.IO;
using System;

namespace _15_csharp
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1) {
                Console.WriteLine("Provide a path of file you'd like to solve");
                Environment.Exit(1);
            }

            List<List<int>> input = readInput(args[0]);
            Console.WriteLine("Day 15:");
            Console.WriteLine("Solution 1: {0}", solution1(input));
            Console.WriteLine("Solution 2: {0}", solution2(input));
        }

        static List<List<int>> readInput(string filePath){
            List<List<int>> input = new List<List<int>>();
            foreach (string line in File.ReadLines(filePath))
            {
                List<int> line_vals = new List<int>();
                foreach (char c in line)
                {
                    line_vals.Add((int)(c - '0'));
                }
                input.Add(line_vals);
            }
            return input;
        }

        static int solution1(List<List<int>> input)
        {
            Dijkstra dijkstra = new Dijkstra(input);
            dijkstra.Run(0, 0);
            return dijkstra.GetDistanceTo(input.Count-1, input[0].Count-1);
        }

        static int solution2(List<List<int>> input)
        {
            List<List<int>> expanded = expandInput(input);
            Dijkstra dijkstra = new Dijkstra(expanded);
            dijkstra.Run(0, 0);
            return dijkstra.GetDistanceTo(expanded.Count-1, expanded[0].Count-1);
        }

        static List<List<int>> expandInput(List<List<int>> input){
            List<List<int>> resizedInp = new List<List<int>>();
            for (int row = 0; row < input.Count * 5; row++){
                List<int> resizedRow = new List<int>();
                for (int col = 0; col < input.Count * 5; col++){
                    int row_inc = row / input.Count;
                    int col_inc = col / input.Count;
                    int row_src = row % input.Count;
                    int col_src = col % input.Count;

                    int new_val = input[row_src][col_src]+row_inc+col_inc;
                    int in_bounds =  ((new_val - 1) % 9) + 1;
                    resizedRow.Add(in_bounds);
                }
                resizedInp.Add(resizedRow);
            }
            return resizedInp;
        }


    }

    class Node
    {
        public int x;
        public int y;
        public int dist;

        public Node(int X, int Y)
        {
            x = X;
            y = Y;
            dist = int.MaxValue;
        }
    }

    class Dijkstra
    {
        private List<List<int>> graph;
        private PriorityQueue<Node, int> pq;
        private Visited v;

        public Dijkstra(List<List<int>> Graph){
            graph = Graph;
            pq = new PriorityQueue<Node, int>();
            for (int i = 0; i < graph.Count; i++){
                for (int j = 0; j < graph[0].Count; j++){
                    Node n = new Node(i, j);
                    pq.Enqueue(n, n.dist);
                }
            }
            Node start = new Node(0, 0);
            start.dist = 0; 
            pq.Enqueue(start, start.dist);
            v = new Visited();
        }

        public void Run(int from_x, int from_y)
        {
            while (!(pq.Count == 0)){
                Node current = pq.Dequeue();
                if (v.WasVisited(current.x, current.y)){
                    continue;
                }
                visit_nb(current.x + 1, current.y    , current);
                visit_nb(current.x    , current.y + 1, current);
                visit_nb(current.x - 1, current.y    , current);
                visit_nb(current.x    , current.y - 1, current);
                v.Add(current.x, current.y, current.dist);
            }
        }

        private void visit_nb(int target_x, int target_y, Node source)
        {
                if ((target_x < 0) || (target_x >= graph.Count)){
                    return;
                }
                if ((target_y < 0) || (target_y >= graph[0].Count)){
                    return;
                }
                if (!v.WasVisited(target_x, target_y)) {
                    int new_dist = source.dist + graph[target_x][target_y];
                    Node target = new Node(target_x, target_y);
                    target.dist = new_dist;
                    pq.Enqueue(target, target.dist);
                }
        }

        public int GetDistanceTo(int x, int y){
            return v.GetDistance(x, y);
        }

    }

    class Visited
    {
        private Dictionary<int, int> visited;

        public Visited(){
            visited = new Dictionary<int, int>();
        }
        public void Add(int x, int y, int dist){
            if (WasVisited(x, y)){
                return;
            }
            visited.Add(getKey(x, y), dist);
        }

        public bool WasVisited(int x, int y){
            return visited.ContainsKey(getKey(x, y));
        }

        public int GetDistance(int x, int y){
            return visited[getKey(x, y)];
        }

        private int getKey(int x, int y){
            return x*1000+y;
        }
    }
}
