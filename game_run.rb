require "io/console"
require "io/wait"
require 'pry'

CSI = "\e["



aliens = "X X X X X"
space_before_aliens = 0
space = "\n\n\n"
player_pos = 5

game_start = Time.now
game_end = false

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
  space_before_aliens = (Time.now - game_start).to_i

  system('clear')
  puts ' ' * space_before_aliens + aliens
  puts space
  puts ' ' * player_pos + '_^-^_'
  input = nil

  STDIN.raw do |io|
    start_read = Time.now
    until (Time.now - start_read) > 0.1
      char = get_char_or_sequence(io)
      if char
        case char
        when 'q', '\x03'
          break
        when "#{CSI}A"
          puts "up \r\n"
        when "#{CSI}B"
          puts "down \r\n"
        when "#{CSI}C"
          player_pos += 1
        when "#{CSI}D"
          player_pos -= 1
        end
      end
    end
  end


  game_end = true if (Time.now - game_start) > 10
end
