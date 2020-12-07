INPUT = File.read_lines("#{__DIR__}/input.txt")

BAG_R = /^(\w+ \w+) bags contain ([^.]*)/
SUBBAG_R = /(\d+) (\w+ \w+)/
NOT_EMPTY = ["shiny gold"]

alias Bag = Tuple(String, String)
alias Contents = Array(Bag)
alias Name = String
alias BagHash = Hash(Name, Contents)

BAGS = INPUT.to_h do |line|
  _, bag, contents = line.match(BAG_R).not_nil!
  {bag, contents.scan(SUBBAG_R).map {|m| {m[1], m[2] }} }
end

def remove_empty(bags : BagHash)
  empty, rest = bags.partition {|_, v| v.empty? }
  return rest if empty.empty?
  pruned = (empty.map(&.first) - NOT_EMPTY).reduce(rest.to_h) do |hsh, e|
    hsh.transform_values! &.reject(&.[1].==(e))
  end
  remove_empty(pruned)
end

def walk(bags : BagHash, key = "shiny gold")
  bags[key].sum(0) do |(count, name)|
    count.to_i + count.to_i * walk(bags, name)
  end
end

p remove_empty(BAGS).size # 179
p walk(BAGS)
