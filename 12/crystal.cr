require "complex"

def parse(input : String)
  input.scan(/([NEWSLRF]{1})(\d+)/).map { |(_, s, i)| {s, i.to_i} }
end

INPUT = parse(File.read("#{__DIR__}/input.txt"))

module Movement
  D2R = Math::PI / 180

  {% for name in %w{+ -} %}
    def {{name.id}}(value : Complex)
      copy_with(loc: self.loc {{name.id}} value)
    end
  {% end %}

  macro included
    alias Move = {{@type}}, Int32 -> {{@type}}
    MOVES = {
      "N" => Move.new { |obj, val| obj + val.i },
      "S" => Move.new { |obj, val| obj - val.i },
      "E" => Move.new { |obj, val| obj + val.to_c },
      "W" => Move.new { |obj, val| obj - val.to_c },
      "L" => Move.new { |obj, val| obj + val },
      "R" => Move.new { |obj, val| obj - val }
    }
    def move(dir, val)
      MOVES[dir].call(self, val)
    end
  end
end

record Ship, loc = Complex.new(0, 0), dir = 0.0 do
  include Movement

  {% for name in %w{+ -} %}
    def {{name.id}}(value : Number)
      copy_with(dir: self.dir {{name.id}} D2R * value)
    end
  {% end %}

  def move(code, value)
    if code == "F"
      self + Complex.new(Math.cos(self.dir) * val, Math.sin(ship.dir) * val)
    else
      previous_def
    end
  end

  def distance(other = Ship.new)
    (self.loc.real.abs + self.loc.imag.abs).to_i
  end
end

record Waypoint, loc = Complex.new(10, 1) do
  include Movement

  {% for name in %w{+ -} %}
    def {{name.id}}(value : Number)
      theta = self.phase {{name.id}} D2R * value
      copy_with(loc: Complex.new(Math.cos(theta) * self.abs, Math.sin(theta) * self.abs))
    end
  {% end %}

  forward_missing_to @loc
end

record BiggerBoat, ship = Ship.new, wp = Waypoint.new do
  def move(dir, value)
    if dir == "F"
      copy_with(ship: ship + (wp * value))
    else
      copy_with(wp: wp.move(dir, value))
    end
  end
end

def solve1
  INPUT.reduce(Ship.new) do |ship, (dir, val)|
    ship.move(dir, val)
  end.distance
end

# pp solve1
def part2
  INPUT.reduce(BiggerBoat.new) do |ship, (dir, value)|
    ship.move(dir, value)
  end.ship.distance
end

pp part2
