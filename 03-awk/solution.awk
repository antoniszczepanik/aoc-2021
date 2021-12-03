#!/usr/bin/awk -f
function binArr2Dec(bitArr){
    acc = 0;
    for (i=0; i < length(bitArr); i++){
        acc += bitArr[i] * (2**(length(bitArr)-i-1));
    }
    return acc;
}

function copyArr(from, to){
    for (i = 0; i < length(from); i++){
        to[i] = from[i];
    }
    # Clean up leftovers, otherwise length does not work.
    to_len = length(to);
    if (length(from) < to_len) {
        for (i = length(from); i < to_len; i++){
            delete to[i];
        }
    }
}

function getCounts(inputLines, outputCounts){
    delete outputCounts;
    for (i = 0; i < length(inputLines); i++){
        split(inputLines[i], chars, "");
        for (j=0; j < length(chars); j++) {
            # Strings are 1-indexed.
            if (chars[j+1] == "0") outputCounts[j] -= 1;
            if (chars[j+1] == "1") outputCounts[j] += 1;
        }
    }
}

function solution1(inputLines){
    getCounts(inputLines, outputCounts);
    for (i=0; i < length(outputCounts); i++) {
        gamma[i]   = outputCounts[i] >= 0;
        epsilon[i] = outputCounts[i] <  0;
    }
    return binArr2Dec(gamma) * binArr2Dec(epsilon);
}

function getCountsAtPos(inputLines, pos){
    getCounts(inputLines, outputCounts);
    return outputCounts[pos];
}

function filterLines(inputLines, isOxyFilter){
    copyArr(inputLines, filteredLines);
    pos = 0;
    while (length(filteredLines) > 1) {
        count = getCountsAtPos(filteredLines, pos);
        if (count >= 0) {
            filter  = isOxyFilter ? "1" : "0";
        } else {
            filter  = isOxyFilter ? "0" : "1";
        }
        newFilteredLinesIndex = 0;
        for (k = 0; k < length(filteredLines); k++){
            if (length(filteredLines[k] > 1)) {
                split(filteredLines[k], chars, "");
                # Strings are 1-indexed.
                if (chars[pos+1] == filter) {
                    newFilteredLines[newFilteredLinesIndex++] = filteredLines[k];
                }
            }
        }
        copyArr(newFilteredLines, filteredLines);
        # Clean it up, otherwise length breaks and cannot copy reliably.
        delete newFilteredLines;
        pos += 1;
    }

    split(filteredLines[0], resultBinArr, "");
    return binArr2Dec(resultBinArr);
}

function solution2(inputLines){
    oxReading       = filterLines(inputLines, 1);
    scrubberReading = filterLines(inputLines, 0);
    return oxReading * scrubberReading;
}

{
    inputLines[NR-1] = $0;
}

END {
    print "Day 3:";
    printf("Solution 1: %d\n", solution1(inputLines));
    printf("Solution 2: %d\n", solution2(inputLines));
}
