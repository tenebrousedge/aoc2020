# frozen_string_literal: true

INPUT = File.readlines("#{__dir__}/input.txt")

BAG_R = /^(\w+ \w+) bags contain ([^.]*)/.freeze
SUBBAG_R = /(\d+) (\w+ \w+)/.freeze
NOT_EMPTY = ['shiny gold'].freeze

bags = INPUT.to_h do |line|
  line.match(BAG_R).then { |m| [m[1], m[2].scan(SUBBAG_R)] }
end

def remove_empty(bags)
  empty, rest = bags.partition { |_, v| v.empty? }
  return rest if empty.empty?

  pruned = (empty.map(&:first) - NOT_EMPTY).reduce(rest.to_h) do |h, e|
    h.transform_values! { |v| v.reject { |_, n| n == e } }
  end
  remove_empty(pruned)
end

def walk(bags, key = 'shiny gold')
  bags[key].sum(0) do |(count, name)|
    count.to_i + count.to_i * walk(bags, name)
  end
end

p remove_empty(bags).size # 179
p walk(bags)
