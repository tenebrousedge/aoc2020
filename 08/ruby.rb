# frozen_string_literal: true

require 'scanf'
require 'set'
require 'pry-byebug'
INPUT = File.readlines("#{__dir__}/input.txt", chomp: true)
            .map { |l| l.scanf('%03s %d') }

# record State, acc = 0, idx = 0
# alias History = Array(State)
State = Struct.new(:idx, :acc) do
  def initialize(*args)
    super
    self.idx ||= 0
    self.acc ||= 0
  end

  def hash
    self.idx
  end

  def ==(other)
    self.idx == other.idx
  end

  alias_method :eql?, :==
end

Program = Struct.new(:instructions, :history) do
  OPS = {
    'nop' => ->(s, _) { State.new(s.idx.succ, s.acc) },
    'acc' => ->(s, val) { State.new(s.idx.succ, s.acc + val) },
    'jmp' => ->(s, val) { State.new(s.idx + val, s.acc) }
  }.freeze

  def eval(state)
    op, val = instructions[state.idx]
    OPS[op].call(state, val)
  end

  def run(state = State.new, limit = nil)
    self.history = Set.new
    limit ||= instructions.size
    while state.idx < instructions.size && state.idx != limit
      break unless history.add? state

      state =  self.eval(state)
    end
    state
  end

  def cycle?(state = State.new)
    f = method(:eval)
    tortoise = f[state]
    hare = f[f[state]]
    while tortoise != hare
      tortoise = f[tortoise]
      hare = f[f[hare]]
    end
    mu = 0
    tortoise = state
    while tortoise != hare
      tortoise = f[tortoise]
      hare = f[hare]
      mu += 1
    end
    lam = 1
    hare = f[tortoise]
    while tortoise != hare
      hare = f[hare]
      lam += 1
    end
    [lam, mu, hare, tortoise]
  end
end
program = Program.new(INPUT)
pp program.run(State.new)
ops = %w[jmp nop]
INPUT.each_with_index.find do |(op, val), idx|
  next unless ops.include? op

  state = Program.new(INPUT.dup.tap { |a| a[idx] = [(ops - [op])[0], val] }).run
  pp state if state.idx == INPUT.size
  state.idx >= INPUT.size
end
