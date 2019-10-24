require "io/console"
require "io/wait"
require 'pry'

CSI = "\e["

Pos = Struct.new(:x, :y)

game_start = Time.now
game_end = false # this can be mutated by player input, dependent on game_start
min_x = 0
max_x = 30
max_y = 4

player_pos = max_x / 2 # this gets mutated by game loop
aliens_start = 6
aliens_last_moved = game_start
aliens_pos = 5.times.collect { |n| Pos.new(0, aliens_start + (n*2) )}
bullet_pos = nil
bullet_fire_time = nil

board = [
  Array.new(aliens_start, ' ').push('X', ' ', 'X', ' ', 'X', ' ', 'X', ' ', 'X', ' '),
  Array.new(max_x, ' '),
  Array.new(max_x, ' '),
  Array.new(max_x, ' '),
  Array.new(player_pos, ' ').push('=' '^', '-', '^', '=')
]

def render(board)
  system 'clear'
  picture = board.collect { |line| line.join('') }.join("\n")
  puts picture
end

# when taking input, there seems to be a 'queue' of inputs
# current implementation of taking input doesn't factor this in

def get_char_or_sequence(io)
  if io.ready?
    result = io.sysread(1)
    while ( CSI.start_with?(result)                        ||
            ( result.start_with?(CSI)                      &&
              !result.codepoints[-1].between?(64, 126) ) ) &&
          (next_char = get_char_or_sequence(io))
      result << next_char
    end
    result
  end
end


until game_end

  # ALIENS MOVE?
  if ((Time.now - aliens_last_moved) * 2) > 1
    board.first.unshift(' ')
    aliens_pos = aliens_pos.collect {|p| Pos.new(p.x, p.y + 1)}
    aliens_last_moved = Time.now
  end

  # BULLET MOVE?
  # if ((Time.now - bullet_fire_time) * 2) > 1
  #   board[bullet_pos.][]
  # end

  # RENDER BOARD
  render(board)

  # TAKE INPUT (MOVE PLAYER / FIRE BULLET)
  STDIN.raw do |io|
    start_read = Time.now
    until (Time.now - start_read) > 0.1
      char = get_char_or_sequence(io)
      if char
        case char

        when 'q', '\x03'    # ctrl+c
          game_end = true

        when "#{CSI}A", ' ' # up
          if bullet_pos.nil?
            board[max_y - 1][player_pos + 2] = "|"
            bullet_pos = Pos.new(max_y - 1, player_pos + 2)
            bullet_fire_time = Time.now
          end
        # when "#{CSI}B"    # down

        when "#{CSI}C", 'l' # right
          if player_pos + 5 < max_x
            board.last.unshift(' ')
            player_pos += 1
          end

        when "#{CSI}D", 'j' # left
          if player_pos > min_x
            board.last.shift
            player_pos -= 1
          end

        end
      end
    end
  end

  # DOES INPUT HAVE CONSEQUENCES?
  # (ship crashes, destroy aliens)


  game_end = true if (Time.now - game_start) > 10
end
