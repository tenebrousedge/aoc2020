INPUT = File.read("#{__DIR__}/input.txt").split("\n\n")

first = INPUT.sum(&.chars.uniq.-(['\n']).size)

second = INPUT.sum do |record|
  chars = record.lines.map(&.chars)
  chars.reduce(chars.first) {|m, e| m & e }.size
end

p first
p second
