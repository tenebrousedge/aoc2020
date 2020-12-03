INPUT = File.read_lines("#{__DIR__}/input.txt")
WIDTH = INPUT[0].size

def slope(dx, dy)
  x = 0
  (dy...INPUT.size).step(dy).count do |y|
    x += dx
    INPUT[y][x % WIDTH] == '#'
  end
end
# puts slope(3, 1) #=> 162 !!
slopes = { {3, 1}, {1, 1}, {5, 1}, {7, 1}, {1, 2} }
puts slopes.map {|(dx, dy)| slope(dx, dy)}.product(&.to_i64)
