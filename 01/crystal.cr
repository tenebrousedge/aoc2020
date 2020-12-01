def solve(arr : Array(Int32), sum : Int32, c = 2)
  arr.each_combination(c, true).find(&.sum.==(sum))
end

arr = File.read_lines("input.txt").map(&.to_i)
if a = solve(arr.sort, 2020)
  puts <<-FOUND
  Found a match!
  Solution is #{a}
  #{a[0]} + #{a[1]} = 2020
  #{a[0]} * #{a[1]} = #{a.product}
  FOUND
else
  puts "no match found!"
end

if (b = solve(arr.sort, 2020, 3))
  puts <<-FOUND
  Found another match! Happy day!
  Solution is #{b}
  #{b[0]} + #{b[1]} + #{b[2]} = 2020
  #{b[0]} * #{b[1]} * #{b[2]} = #{b.product}
  FOUND
else
  puts "no match found!"
end

