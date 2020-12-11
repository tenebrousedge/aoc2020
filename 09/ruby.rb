# frozen_string_literal: true

require 'pry-byebug'
INPUT = File.readlines("#{__dir__}/input.txt", chomp: true).map(&:to_i)

sample = %w[35 20 15 25 47 40 62 55 65 95 102 117 150 182
            127 219 299 277 309 576].map(&:to_i)
def invalid?(arr)
  *head, last = arr
  head.combination(2).map(&:sum).none?(last)
end

def subsum(arr, k)
  start = 0
  arr.each_with_index.reduce do |(sum, _), (elem, idx)|
    while sum > k && start < idx
      sum -= arr[start]
      start += 1
    end
    break [start, idx] if sum == k

    sum + elem
  end
end
a = sample.each_cons(6).find(&method(:invalid?)).last
pp a
b = INPUT.each_cons(26).find(&method(:invalid?)).last
pp b
pp subsum(INPUT, 31161678).then {|s, e| INPUT[s..e].minmax.sum }
