seats = File.read_lines("#{__DIR__}/input.txt").map(&.tr("FBLR", "0101").to_i(2))
puts seats.max
puts seats.select { |x| !(x + 1).in?(seats) }.min + 1
