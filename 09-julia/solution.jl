using Printf

function readNums(filePath)
    lines = filter(l -> length(l) > 1, split(open(f->read(f, String), filePath), "\n"))
    nums = map(ln -> [parse(Int8, char) for char in split(ln, "")], lines)
    return hcat(nums...)'
end

function solution1(nums)
    mask = trues(size(nums))
    # left to right
    for column = 1:(size(nums, 2)-1)
        mask[:,column] = mask[:,column] .& (nums[:,column] .< nums[:,column+1])
    end
    # right to left
    for column = 2:size(nums, 2)
        mask[:,column] = mask[:,column] .& (nums[:,column] .< nums[:,column-1])
    end
    # top to bottom
    for row = 1:(size(nums, 1)-1)
        mask[row,:] = mask[row,:] .& (nums[row,:] .< nums[row+1,:])
    end
    # bottom to top
    for row = 2:size(nums, 1)
        mask[row,:] = mask[row,:] .& (nums[row,:] .< nums[row-1,:])
    end
    return sum(nums[mask] .+ 1)
end

function solution2(nums)
    borders = nums .== 9
    function bfs(p_row, p_col)
        # out of bounds
        if (p_row < 1 || p_row > size(borders, 1) || p_col < 1 || p_col > size(borders, 2))
            return 0
        end
        # already visited or border
        if borders[p_row, p_col]
            return 0
        end
        borders[p_row, p_col] = 1
        return (1 
                + bfs(p_row + 1, p_col    )
                + bfs(p_row - 1, p_col    )
                + bfs(p_row    , p_col + 1)
                + bfs(p_row    , p_col - 1))
    end
    basin_counts = zeros(Int64, 0)
    for col = 1:(size(borders, 2))
        for row = 1:(size(borders, 1))
            res = bfs(row, col)
            if res != 0
                append!(basin_counts, res)
            end
        end
    end
    largest3 = sort(basin_counts)[end-2:end]
    return largest3[1] * largest3[2] * largest3[3]
end


if length(ARGS) < 1
	println("Provide path of a file you'd like to solve")
	exit(1)
end

nums = readNums(ARGS[1])
println("Day 9:");
Printf.@printf "Solution 1: %d\n" solution1(nums)
Printf.@printf "Solution 2: %d\n" solution2(nums)
