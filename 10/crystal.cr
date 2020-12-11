numbers = File.read_lines("#{__DIR__}/input.txt").map(&.to_i).sort.unshift(0)
numbers.push(numbers.last + 3)

counts = numbers.each.cons(2).map { |(x, y)| y - x }.tally
p counts[1] * counts[3]

subs = numbers[..-2].each_with_index.to_h do |(n, idx)|
  {n, numbers[idx.succ..].take_while(&.-(n).<=(3)) }
end

second = (subs.keys.reverse_each).each_with_object({numbers.last => 1_u64}) do |n, memo|
  memo[n] = subs[n].sum(&->memo.[](Int32))
end[0]

p second
