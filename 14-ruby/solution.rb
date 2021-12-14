def read_input(filename)
  if not File.file?(filename)
    STDERR.puts("#{filename}: no such file or directory") 
    exit 1
  end
  rules = Hash.new
  template = ""
  File.foreach(filename).with_index do |line, line_num|
    if line_num == 0
      template = line.strip
    else
      if line.length > 1
        splitted = line.strip.split(" -> ", 2)
        rules[splitted[0]] = splitted[1]
      end
    end
  end
  return template, rules
end

def merge_counters(a, b)
  return a.merge(b){ |k, a_value, b_value| a_value + b_value }
end

def solution(template, rules, times)
  memo = Hash.new
  def count(pair, rules, depth, m)
    mkey = "#{pair}#{depth}"
    if m.key?(mkey)
      return m[mkey]
    end
    if depth == 0
      return {pair[0] => 1}
    end
    merged = merge_counters(
      count(pair[0] + rules[pair], rules, depth-1, m),
      count(rules[pair] + pair[1], rules, depth-1, m),
    )
    m[mkey] = merged
    return merged
  end

  c = Hash.new
  0.step(template.size-2,1).each do |i|
    c = merge_counters(c, count(template[i]+template[i+1], rules, times, memo))
  end
  c[template[template.size-1]] += 1
  c.values.max - c.values.min
end


def solution1(template, rules)
  solution(template, rules, 10)
end

def solution2(template, rules)
  solution(template, rules, 40)
end


if ARGV.length < 1
  STDERR.puts("Provide a path of a file you'd like to solve") 
  exit 1
end

template, rules = read_input(ARGV[0])
puts "Day 14:"
puts "Solution 1: #{solution1(template, rules)}"
puts "Solution 2: #{solution2(template, rules)}"
