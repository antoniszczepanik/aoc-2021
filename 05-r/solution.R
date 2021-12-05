#!/usr/bin/env Rscript

getFileLines = function(fileName){
    f = file(fileName, "r")
    inputLines = readLines(f)
    close(f)
    return(inputLines)
}

getInput = function(fileName){
    inputLines = strsplit(getFileLines(fileName), "( -> |,)")
    lines = list()
    for(i in 1:length(inputLines)){
        newLine = createLine(
                               as.numeric(inputLines[[i]][2]),
                               as.numeric(inputLines[[i]][4]),
                               as.numeric(inputLines[[i]][1]),
                               as.numeric(inputLines[[i]][3])
        )
        lines[[i]] = newLine
    }
    return(lines)
}

createLine = function(x1, y1, x2, y2){
    return(list(x1=x1, x2=x2, y1=y1, y2= y2))
}

createPoint = function(x1, x2){
    return(list(x1=x1, x2=x2))
}

filterLines = function(lines){
    filtered = list()
    offset = 1
    for(row_i in 1:length(lines)) {
        l = lines[[row_i]]
        if ((l$x1 == l$y1)|(l$x2 == l$y2)){
            filtered[[offset]] = l
            offset = offset + 1
        }
    }
    return(filtered)
}

getInterpolatedPoints1 = function(lines){
    interpolated = list()
    offset = 1
    for(row_i in 1:length(lines)) {
        l = lines[[row_i]]
        if (l$x1 == l$y1) {
            for(v2 in l$x2:l$y2){
                interpolated[[offset]] =  createPoint(l$x1, v2)
                offset = offset + 1
            }
        }
        if (l$x2 == l$y2) {
            for(v1 in l$x1:l$y1){
                interpolated[[offset]] =  createPoint(v1, l$x2)
                offset = offset + 1
            }
        }
    }
    return(interpolated)
}

getMax = function(points) {
    max = 0
    for (point in points){
        if (point$x1 > max) {
            max = point$x1
        }
        if (point$x2 > max) {
            max = point$x2
        }
    }
    return(max)

}

getCounts = function(points) {
    max = getMax(points)
    counts = matrix(0, nrow=max+1, ncol=max+1)
    for (p in points){
        counts[p$x1+1, p$x2+1] = counts[p$x1+1, p$x2+1] + 1
    }
    return(counts)
}


solution1 = function(fileName){
    lines = getInput(fileName)
    filtered = filterLines(lines)
    points = getInterpolatedPoints1(lines)
    counts = getCounts(points)
    return(length(which(counts >= 2)))
}

getInterpolatedPoints2 = function(lines){
    interpolated = list()
    offset = 1
    for(row_i in 1:length(lines)) {
        l = lines[[row_i]]
        if (l$x1 == l$y1) {
            for(v2 in l$x2:l$y2){
                interpolated[[offset]] =  createPoint(l$x1, v2)
                offset = offset + 1
            }
        } else if (l$x2 == l$y2) {
            for(v1 in l$x1:l$y1){
                interpolated[[offset]] =  createPoint(v1, l$x2)
                offset = offset + 1
            }
        } else if (abs(l$x1 - l$y1) == abs(l$x2 - l$y2)){
            if (l$x1 < l$y1){
                firstFromLeft = createPoint(l$x1, l$x2)
                direction = as.numeric(l$x2 < l$y2)
                if (direction == 0) {
                    direction = -1
                }
            } else {
                firstFromLeft = createPoint(l$y1, l$y2)
                direction = as.numeric(l$y2 < l$x2)
                if (direction == 0) {
                    direction = -1
                }
            }
            diff = abs(l$x1 - l$y1)
            for(d in 0:diff){
                p1 = firstFromLeft$x1 + d
                p2 = firstFromLeft$x2 + (d*direction)
                interpolated[[offset]] =  createPoint(p1, p2)
                offset = offset + 1
            }

        }

    }
    return(interpolated)
}

solution2 = function(fileName){
    lines = getInput(fileName)
    points = getInterpolatedPoints2(lines)
    counts = getCounts(points)
    return(length(which(counts >= 2)))
}


fileName = commandArgs(trailingOnly=TRUE)[1]

print("Day 5:")
sprintf("Solution 1: %d", solution1(fileName))
sprintf("Solution 2: %d", solution2(fileName))
