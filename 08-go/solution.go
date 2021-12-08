package main

import (
    "flag"
    "fmt"
    "io/ioutil"
    "os"
    "sort"
    "strings"
)

func readLines(filePath string) []string {
    input, err := ioutil.ReadFile(filePath)
    if err != nil {
        fmt.Fprintf(os.Stderr, "%s\n", err.Error())
        os.Exit(1)
    }
    return strings.Split(string(input), "\n")
}

func solution1(lines []string) int {
    acc := 0
    for _, line := range lines {
        if len(line) == 0 {
            continue
        }
        r_part := strings.Split(line, " | ")[1]
        nums := strings.Split(r_part, " ")
        for _, num := range nums {
            l := len(num)
            if l == 2 || l == 3 || l == 4 || l == 7 {
                acc += 1
            }
        }
    }
    return acc
}

// Yes, this happened :(
func makePerms() [][7]byte {
    var perms [][7]byte
    possible := []int{0, 1, 2, 3, 4, 5, 6}
    var curr_perm [7]byte
    for p := make([]int, len(possible)); p[0] < len(p); nextPerm(p) {
        perm := getPerm(possible, p)
        for i, value := range perm {
            curr_perm[i] = i2b(value)
        }
        perms = append(perms, curr_perm)
    }
    return perms
}

func getPerm(orig, p []int) []int {
    result := append([]int{}, orig...)
    for i, v := range p {
        result[i], result[i+v] = result[i+v], result[i]
    }
    return result
}

func nextPerm(p []int) {
    for i := len(p) - 1; i >= 0; i-- {
        if i == 0 || p[i] < len(p)-i-1 {
            p[i]++
            return
        }
        p[i] = 0
    }
}

func translate(word string, perm [7]byte) string {
    translated := make([]byte, len(word))
    for i := range word {
        translated[i] = perm[b2i(word[i])]
    }
    return string(translated)
}

var digits_rev = map[string]int{
    "abcefg":  0,
    "cf":      1,
    "acdeg":   2,
    "acdfg":   3,
    "bcdf":    4,
    "abdfg":   5,
    "abdefg":  6,
    "acf":     7,
    "abcdefg": 8,
    "abcdfg":  9,
}

func getValue(word string) (int, bool) {
    s := strings.Split(word, "")
    sort.Strings(s)
    d, ok := digits_rev[strings.Join(s, "")]
    return d, ok
}

func getNumber(word string, perm [7]byte) (int, bool) {
    return getValue(translate(word, perm))
}

func solution2(lines []string) int {
    var l_part [10]string
    var r_part [4]string
    var result int
    for _, line := range lines {
        if len(line) == 0 {
            continue
        }
        splitted := strings.Split(line, " | ")
        for i, l := range strings.Split(splitted[0], " ") {
            l_part[i] = l
        }
        for i, r := range strings.Split(splitted[1], " ") {
            r_part[i] = r
        }

        var matched bool
        for _, perm := range makePerms() {
            matched = true
            for _, w := range l_part {
                newWord := translate(w, perm)
                if _, ok := getValue(newWord); !ok {
                    matched = false
                    break
                }

            }
            if matched {
                var digits [4]int
                for i, w := range r_part {
                    digit, ok := getNumber(w, perm)
                    if !ok {
                        fmt.Fprintf(os.Stderr, "could not get translation for %s\n", w)
                        os.Exit(1)
                    }
                    digits[i] = digit
                }
                result += 1000*digits[0] + 100*digits[1] + 10*digits[2] + digits[3]
                break
            }
        }
    }
    return result
}


func i2b(i int) byte {
    switch i {
    case 0:
        return 'a'
    case 1:
        return 'b'
    case 2:
        return 'c'
    case 3:
        return 'd'
    case 4:
        return 'e'
    case 5:
        return 'f'
    default:
        return 'g'
    }
}

func b2i(b byte) int {
    switch b {
    case 'a':
        return 0
    case 'b':
        return 1
    case 'c':
        return 2
    case 'd':
        return 3
    case 'e':
        return 4
    case 'f':
        return 5
    default:
        return 6
    }
}

func main() {
    flag.Parse()
    args := flag.Args()
    if len(args) < 1 {
        fmt.Fprintf(os.Stderr, "You should specify a file you'd like to solve\n")
        os.Exit(1)
    }

    lines := readLines(args[0])
    fmt.Println("Day 8:")
    fmt.Printf("Solution 1: %d\n", solution1(lines))
    fmt.Printf("Solution 2: %d\n", solution2(lines))
}
