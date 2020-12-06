INPUT = File.read("#{__DIR__}/input.txt").split("\n\n")

first = INPUT.sum(&.chars.uniq.-(['\n']).size)

second = INPUT.sum do |record|
  record.lines.map(&.chars).reduce {|m, e| m & e }.size
end

p first
p second
