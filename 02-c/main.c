#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINE_LEN sizeof("forward X\n")

typedef struct {
    int depth;
    int x;
    int aim;
} Position;

typedef enum {
    DOWN,
    UP,
    FORWARD,
} CommandT;

typedef struct {
    CommandT type;
    int value;
} Command;

int count_lines(FILE *file){
    char ch;
    int count = 0;
    while(!feof(file))
    {
        ch = fgetc(file);
        if(ch == '\n')
        {
            count++;
        }
    }
    fseek(file, 0, SEEK_SET);
    return count;
}

Command* get_input(char* filename, int *size)
{
    FILE* file;
    file = fopen(filename, "r");
    if (file == NULL) {
        fprintf(stderr, "ERROR: could not open %s: %s\n", filename, strerror(errno));
        exit(1);
    }
    
    *size = count_lines(file);
    Command *commands = malloc(*size * sizeof(Command));

    char buffer[MAX_LINE_LEN];
    fgets(buffer, MAX_LINE_LEN, file);
    for(int i = 0; i<*size; i++) {
        int value;
        char command_name[MAX_LINE_LEN-2];
        sscanf(buffer, "%s %d", command_name, &value);
        if (strcmp(command_name, "forward") == 0) 
        {
            Command cmd = {.type = FORWARD, .value = value};
            commands[i] = cmd;
        } 
        else if (strcmp(command_name, "down") == 0)
        {
            Command cmd = {.type = DOWN, .value = value};
            commands[i] = cmd;
        }
        else if (strcmp(command_name, "up") == 0)
        {
            Command cmd = {.type = UP, .value = value};
            commands[i] = cmd;
        }
        fgets(buffer, MAX_LINE_LEN, file);
    }
    fclose(file);
    return commands;
}

int solution1(char* filename)
{
    int size;
    Command *cmds = get_input(filename, &size);
    Position p = { .depth = 0, .x = 0 };
    for (int i = 0; i < size; i++){
        switch (cmds[i].type) {
            case FORWARD:
                p.x += cmds[i].value;
                break;
            case UP:
                p.depth -= cmds[i].value;
                break;
            case DOWN:
                p.depth += cmds[i].value;
                break;
            default:
                fprintf(stderr, "ERROR: unknown command");
                exit(1);
        }
    }
    free(cmds);
    return p.depth * p.x;
}

int solution2(char* filename)
{
    int size;
    Command *cmds = get_input(filename, &size);
    Position p = { .depth = 0, .x = 0, .aim = 0 };
    for (int i = 0; i < size; i++){
        switch (cmds[i].type) {
            case FORWARD:
                p.x += cmds[i].value;
                p.depth += cmds[i].value * p.aim;
                break;
            case UP:
                p.aim -= cmds[i].value;
                break;
            case DOWN:
                p.aim += cmds[i].value;
                break;
            default:
                fprintf(stderr, "ERROR: unknown command");
                exit(1);
        }
    }
    free(cmds);
    return p.depth * p.x;
}

int main(int argc, char** argv)
{
    if (argc < 2) {
        fprintf(stderr, "ERROR: no file name passed\n");
        exit(1);
    }
    printf("Day 2:\n");
    printf("Solution 1: %d\n", solution1(argv[1]));
    printf("Solution 2: %d\n", solution2(argv[1]));
}
