# frozen_string_literal: true

input = File.readlines("#{__dir__}/input.txt").map(&:to_i)

def solve(arr, sum, k = 2)
  arr.combination(k).find { |c| c.sum == sum }
end

if (a = solve(input.sort, 2020))
  puts <<-FOUND
  Found a match!
  Solution is #{a}
  #{a[0]} + #{a[1]} = 2020
  #{a[0]} * #{a[1]} = #{a.product}
  FOUND
else
  puts 'no match found!'
end

if (b = solve(input.sort, 2020, 3))
  puts <<-FOUND
  Found another match! Happy day!
  Solution is #{b}
  #{b[0]} + #{b[1]} + #{b[2]} = 2020
  #{b[0]} * #{b[1]} * #{b[2]} = #{b.product}
  FOUND
else
  puts 'no match found!'
end
