INPUT = File.read("#{__DIR__}/input.txt")

record Point, x : Int32, y : Int32 do
  def +(other : Point)
    self.class.new(self.x + other.x, self.y + other.y)
  end

  def self.new(arr : Array(Int32))
    raise ArgumentError.new unless arr.size == 2
    new(arr[0], arr[1])
  end
end

record Cell, location : Point, value : CellType do
  enum CellType
    Empty
    Full
    Floor
  end

  KEY = "L#."

  def self.new(x : Int32, y : Int32, value : Char)
    new(Point.new(x, y), CellType.from_value(KEY.index(value).not_nil!))
  end

  def self.from_string(s : String)
    s.split.map_with_index do |line, y|
      line.chars.map_with_index { |c, x| new(x, y, c) }
    end
  end

  def evolve(neighbors : Array(Cell), tolerance = 4)
    return self if floor?

    fn = neighbors.select(&.full?).size
    if full? && fn >= tolerance
      copy_with(value: CellType::Empty)
    elsif empty? && fn.zero?
      copy_with(value: CellType::Full)
    else
      self
    end
  end

  def to_s
    KEY[self.value.value]
  end

  delegate floor?, full?, empty?, to: @value
end

class World
  alias Row = Array(Cell)
  alias Map = Array(Row)
  alias Area = Array(CellIterator)

  NEIGHBORHOOD = [0, 1, -1].repeated_permutations(2)
    .-([[0, 0]])
    .map(&->Point.new(Array(Int32)))

  protected getter map

  def initialize(@map : Map, &evolver : Cell, Area -> Cell)
    @evolver = evolver
  end

  def self.new(input : String, &evolver : Cell, Area -> Cell)
    new(Cell.from_string(input), &evolver)
  end

  def self.new(input : String)
    default = ->(cell : Cell, area : Area) do
      cell.evolve(area.map(&.next).reject(Iterator::Stop), tolerance: 4)

    end
    new(input, &default)
  end

  def in_bounds?(location : Point)
    0 <= location.x < @map[0].size && 0 <= location.y < @map.size
  end

  def neighbors(cell : Cell)
    NEIGHBORHOOD.map do |dir|
      CellIterator.new(self, cell.location, dir)
    end
  end

  def evolve_all
    @map = @map.map do |row|
      row.map do |cell|
        @evolver.call(cell, neighbors(cell))
      end
    end
  end

  def occupied
    @map.sum(&.count(&.full?))
  end

  def print
    puts @map.join('\n', &.join(&.to_s))
  end

  def_equals_and_hash @map
  forward_missing_to @map

  private class CellIterator
    include Iterator(Cell)

    def initialize(@world : World, @curr : Point, @dir : Point); end

    def next
      @curr = @curr + @dir
      @world.in_bounds?(@curr) ? @world[@curr.y][@curr.x] : stop
    end
  end
end

class Interpreter
  def initialize(@world : World, @history = Set(UInt64).new); end

  def run
    while @history.add? @world.hash
      @world.evolve_all
    end
    @world
  end

  def self.part1
    Interpreter.new(World.new(INPUT) do |cell, area|
      cell.evolve(area.map(&.next).reject(Iterator::Stop), tolerance: 4)
    end).run.occupied # 2166
  end

  def self.part2
    Interpreter.new(World.new(INPUT) do |cell, area|
      cell.evolve(area.compact_map(&.find(&.floor?.!)), tolerance: 5)
    end).run.occupied
  end
end

require "spec"
describe World do
  it "evolves" do
    test1 = World.new("LLL\nLLL\nLLL")
    test1.evolve_all
    test1.should eq World.new("###\n###\n###")
    test1.evolve_all
    test1.should eq World.new("#L#\nLLL\n#L#")
    test2 = World.new("L..\n...\n...")
    test2.evolve_all
    test2.should eq World.new("#..\n...\n...")
    test3 = World.new("##\n##")
    test3.evolve_all
    test3.should eq World.new("##\n##")
    test4 = World.new("###\n###\n###")
    test4.evolve_all
    test4.should eq World.new("#L#\nLLL\n#L#")
  end

  it "evolves the sample correctly" do
    world = World.new(<<-SAMPLE)
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
    SAMPLE
    step1 = World.new(<<-STEP1)
    #.##.##.##
    #######.##
    #.#.#..#..
    ####.##.##
    #.##.##.##
    #.#####.##
    ..#.#.....
    ##########
    #.######.#
    #.#####.##
    STEP1
    step2 = World.new(<<-STEP2)
    #.LL.L#.##
    #LLLLLL.L#
    L.L.L..L..
    #LLL.LL.L#
    #.LL.LL.LL
    #.LLLL#.##
    ..L.L.....
    #LLLLLLLL#
    #.LLLLLL.L
    #.#LLLL.##
    STEP2
    step3 = World.new(<<-STEP3)
    #.##.L#.##
    #L###LL.L#
    L.#.#..#..
    #L##.##.L#
    #.##.LL.LL
    #.###L#.##
    ..#.#.....
    #L######L#
    #.LL###L.L
    #.#L###.##
    STEP3
    step4 = World.new(<<-STEP4)
    #.#L.L#.##
    #LLL#LL.L#
    L.L.L..#..
    #LLL.##.L#
    #.LL.LL.LL
    #.LL#L#.##
    ..L.L.....
    #L#LLLL#L#
    #.LLLLLL.L
    #.#L#L#.##
    STEP4
    step5 = World.new(<<-STEP5)
    #.#L.L#.##
    #LLL#LL.L#
    L.#.L..#..
    #L##.##.L#
    #.#L.LL.LL
    #.#L#L#.##
    ..L.L.....
    #L#L##L#L#
    #.LLLLLL.L
    #.#L#L#.##
    STEP5
    world.evolve_all
    world.should eq step1
    world.evolve_all
    world.should eq step2
    world.evolve_all
    world.should eq step3
    world.evolve_all
    world.should eq step4
    world.evolve_all
    world.should eq step5
    world.sum(&.select(&.full?).size).should eq 37
  end

  it "has runs" do
    world = Interpreter.new(World.new(<<-SAMPLE)).run
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
    SAMPLE
    step5 = World.new(<<-STEP5)
    #.#L.L#.##
    #LLL#LL.L#
    L.#.L..#..
    #L##.##.L#
    #.#L.LL.LL
    #.#L#L#.##
    ..L.L.....
    #L#L##L#L#
    #.LLLLLL.L
    #.#L#L#.##
    STEP5
    world.should eq step5
    world.sum(&.select(&.full?).size).should eq 37
  end

  it "solves part 1 correctly" do
    Interpreter.part1.should eq 2166
  end

  it "finds visible neighbors" do
    test1 = World.new(<<-FIRST)
    .......#.
    ...#.....
    .#.......
    .........
    ..#L....#
    ....#....
    .........
    #........
    ...#.....
    FIRST
    neighbors = test1.neighbors(test1[4][3]).compact_map(&.find(&.floor?.!))
    neighbors.size.should eq 8
    neighbors.select(&.full?).size.should eq 8
  end
  
  it "solves part 2" do
    Interpreter.part2.should eq 1955
  end
end
