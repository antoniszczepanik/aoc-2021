import sys

from typing import Callable, List


def get_input(file_path: str) -> List[int]:
    with open(file_path, "r") as f:
        return [int(n) for n in f.read().split(",")]


def get_fuel_cost(nums: List[int], valfun: Callable[[int, int], int]) -> int:
    result = 69_69_69_69_69_69_69
    for threshold in range(min(nums), max(nums) + 1):
        result = min(result, sum([valfun(x, threshold) for x in nums]))
    return result


def solution1(file_path: str) -> int:
    nums = get_input(file_path)
    return get_fuel_cost(nums, lambda x, y: abs(x - y))


def solution2(file_path: str) -> int:
    nums = get_input(file_path)
    return get_fuel_cost(nums, lambda x, y: (abs(x - y) * (abs(x - y) + 1) // 2))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Provide a name of a file to solve")
        sys.exit(1)

    print("Day 7:")
    print(f"Solution 1: {solution1(sys.argv[1])}")
    print(f"Solution 2: {solution2(sys.argv[1])}")
    sys.exit(0)
