#include <cstring>
#include <fstream>
#include <iostream>
#include <stdio.h>

using namespace std;

#define GRID_SIZE 10

int grid[GRID_SIZE][GRID_SIZE] = { 0 };
int after_flash[GRID_SIZE][GRID_SIZE] = { false };

bool isOut(int col, int row){
    return ((row > GRID_SIZE-1) || (col > GRID_SIZE-1) || (row < 0) || (col < 0));
}

int readInput(string filePath){
    char ch;
    int row = 0; int col = 0; int val = 0;
    fstream fin(filePath, fstream::in);
    while (fin >> noskipws >> ch) {
        if (ch == '\n') {
            col++;
            row = 0;
            continue;
        }
        val = ch - '0';
        if (isOut(col, row)) {
            fprintf(stderr, "ERROR: Input out of expected size %d\n", GRID_SIZE);
            exit(1);
        }
        if ((val < 0) || (val > 9)) {
            fprintf(stderr, "ERROR: Non numeric char: %d\n", ch);
            exit(1);
        }
        grid[col][row++] = val;
    }
    return 0;
}

int flash(int col, int row){
    if (isOut(col, row) || after_flash[col][row]) return 0;
    if (grid[col][row] == 9){
        grid[col][row] = 0;
        after_flash[col][row] = true;
        return (1 + 
                flash(col+1,row  ) +
                flash(col  ,row+1) +
                flash(col-1,row  ) +
                flash(col  ,row-1) +
                flash(col+1,row+1) +
                flash(col-1,row-1) +
                flash(col-1,row+1) +
                flash(col+1,row-1));
    }
    grid[col][row] += 1;
    return 0;
}

int next_step(){
    int flashes = 0;
    for (int col = 0; col < GRID_SIZE; col++){
        for (int row = 0; row < GRID_SIZE; row++){
            flashes += flash(col, row);
        }
    }
    memset(after_flash, false, sizeof after_flash);
    return flashes;
}

int solution1(string filePath){
    readInput(filePath);
    int result = 0;
    for (int step = 0; step < 100; step++){
        result += next_step();
    }
    return result;
}

int solution2(string filePath){
    readInput(filePath);
    int n_flashes = 0; int step = 0;
    while (true) {
        n_flashes = next_step();
        step += 1;
        if (n_flashes == (GRID_SIZE * GRID_SIZE)){
            return step; 
        }
    }
    return -1;
}

int main(int argc, char **argv){
    if (argc < 2) {
            fprintf(stderr, "Provide path of a file you'd like to solve\n");
            exit(1);
    }
    string f = argv[1];
    cout << "Day 11:" << endl;
    cout << "Solution 1: " << solution1(f) << endl;
    cout << "Solution 2: " << solution2(f) << endl;
}
