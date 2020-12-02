REGEX = /(\d+)-(\d+) ([a-z]): ([a-z]+)/
inputs = File.read("#{__DIR__}/input.txt").scan(REGEX)

first_solution = inputs.count do |(_, min, max, char, password)|
  min.to_i <= password.count(char) <= max.to_i
end

puts first_solution

second_solution = inputs.count do |(_, first, second, char, password)|
  (password[first.to_i.pred] == char[0]) ^ (password[second.to_i.pred] == char[0])
end

puts second_solution
