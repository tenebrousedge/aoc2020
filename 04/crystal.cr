alias Rule = Proc(String, Bool)
alias Matches = Array(Regex::MatchData)

record Passport, matches : Matches do
  FIELDS = ["byr", "ecl", "eyr", "hcl", "hgt", "iyr", "pid"]

  FIELD_REGEX = /([a-z]{3}(?<!cid)):(\S+)/

  RULES = {
    "byr" => Rule.new { |s| s.matches?(/^\d{4}$/) && ("1920" <= s <= "2002") },
    "iyr" => Rule.new { |s| s.matches?(/^\d{4}$/) && ("2010" <= s <= "2020") },
    "eyr" => Rule.new { |s| s.matches?(/^\d{4}$/) && ("2020" <= s <= "2030") },
    "hgt" => Rule.new { |s| !!s.match(/^(\d{2,3})(cm|in)$/).try { |(_, n, u)| u == "in" ? ("59" <= n <= "76") : ("150" <= n <= "193") } },
    "hcl" => Rule.new { |s| s.matches?(/^#[0-9a-f]{6}$/) },
    "ecl" => Rule.new { |s| s.matches?(/^(amb|blu|brn|gry|grn|hzl|oth)$/) },
    "pid" => Rule.new { |s| s.matches?(/^\d{9}$/) },
  }

  def self.from_string(record : String)
    new(record.scan(FIELD_REGEX))
  end

  def all_required?
    (FIELDS - @matches.map(&.[1])).empty?
  end

  def fields_valid?
    @matches.all? { |(_, field, data)| RULES[field].call(data) }
  end
end

RECORDS = File.read("#{__DIR__}/input.txt").split("\n\n").map(&->Passport.from_string(String))

first = RECORDS.count(&.all_required?)

second = RECORDS.count { |r| r.all_required? && r.fields_valid? }

p first
p second
