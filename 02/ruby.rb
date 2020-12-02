require 'scanf'

str = "%d%*c%d %c: %s"

inputs = File.readlines("#{__dir__}/input.txt").map {|s| s.scanf(str) }

puts inputs.count {|(min, max, char, pass)| (min..max).cover? pass.count(char) }
puts inputs.count {|(a, b, char, pass)| pass[a.pred].==(char) ^ pass[b.pred].==(char) }
