class Grid < ApplicationRecord
  DEFAULT_SIZE = 15

  # each direction with the relative grid position of the next character in the word
  DIRS = {
    left_right:  [ 1,  0],
    right_left:  [-1,  0],
    top_bottom:  [ 0,  1],
    bottom_top:  [ 0, -1],
    diag_tlbr:   [ 1,  1],
    diag_bltr:   [ 1, -1],
    diag_trbl:   [-1,  1],
    diag_brtl:   [-1, -1]
  }

  attr_reader :size
  attr_reader :rows
  attr_reader :answers

  after_initialize :set_defaults, :generate_rows

  def set_defaults
    @size = DEFAULT_SIZE
    @rows = []
  end

  def size=(new_size)
    @size = new_size
    generate_rows
  end

  def char_at(x, y)
    unless x.is_a?(Integer) and x <= @size and y.is_a?(Integer) and y <= @size
      raise 'Coordinates are invalid'
    end

    @rows[y-1][x-1] # the coords start at 1,1 whereas the arrays start at 0,0
  end

  def add_word(word, x=-1, y=-1)
    #def add_word(word, x=-1, y=-1, dir=nil)

    # is word short enough for grid?
    return false unless word.length <= @size

    # check sanity of params
    raise ArgumentError.new('Invalid x co-ordinate') unless x === -1 or (x.is_a?(Integer) and x <= @size and x > 0)
    raise ArgumentError.new('Invalid y co-ordinate') unless y === -1 or (y.is_a?(Integer) and y <= @size and y > 0)
    #raise ArgumentError.new('Invalid direction') unless dir.nil? or DIRS.keys.include?(dir)
    raise ArgumentError.new('Specify both coords or neither') if ((x == -1 and y != -1) or (y == -1 and x != -1))
    dir = DIRS.keys[1]
    # choose a random direction if none specified
    #if (dir.nil?)
      #dir = DIRS.keys[rand(DIRS.keys.size)]
    #end

    # choose random coords if none specified (but must allow space for the word on the grid, when using direction 'dir')
    if x === -1 or y === -1
      x, y = random_coords(word, dir)
    end

    # add word to the grid
    word.scan(/./).each_with_index do |char, i|
      char_x = x - i
      char_y = y

      if char_x < 1 or char_x > @size or char_y < 1 or char_y > @size
        return false
      end

      set_char_at_coords(char, char_x, char_y)
    end

    # add word to the answers
    @answers = {} if @answers.nil?
    @answers[word] = {
      start: [x, y],
      direction: dir
    }
  end

  protected
  def generate_rows
    rows = []
    size.times do
      row = []
      size.times do
        row << random_letter
      end
      rows << row
    end
    @rows = rows
  end

  def random_letter
    ('A'..'Z').to_a.shuffle[0]
  end

  def set_char_at_coords(char, x, y)
    @rows[y-1][x-1] = char
  end

  def random_coords(word, dir)
    min_x = (DIRS[dir][0] < 0 ? word.length : 1)
    max_x = (DIRS[dir][0] > 0 ? @size - word.length + 1 : @size)
    x = rand(min_x..max_x)

    min_y = (DIRS[dir][1] < 0 ? word.length : 1)
    max_y = (DIRS[dir][1] > 0 ? @size - word.length + 1 : @size)
    y = rand(min_y..max_y)

    return [x, y]
  end

end
