# frozen_string_literal: true

INPUT = File.readlines("#{__dir__}/input.txt", chomp: true)
WIDTH = INPUT[0].size

def slope(dx, dy)
  x = 0
  (dy...INPUT.size).step(dy).count do |y|
    x += dx
    INPUT[y][x % WIDTH] == '#'
  end
rescue ArgumentError
  raise "dy: #{dy}, isize: #{INPUT.size}"
end

puts slope(3, 1) # => 162
slopes = [[3, 1], [1, 1], [5, 1], [7, 1], [1, 2]]
puts slopes.map {|s| slope(*s) }.reduce(:*)
