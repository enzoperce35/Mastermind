module Game
  DEF_COLORS = "\nr = red        o = orange     y = yellow",
                "g = green      b = blue ",
                "i = indigo     v = violet\n"
  COLOR_HASH = {:r => 'Red', :o => 'Orange', :y => 'Yellow',
                :g => 'Green', :b => 'Blue', :i => 'Indigo',
                :v => 'Violet'}
  COLOR_PERMUTATIONS = 'roygbiv'.split('').permutation(5).to_a
  COLOR_KEYS = ['r', 'o', 'y', 'g', 'b', 'i', 'v']
  LINE_SPACES_2 = "\n\n"
  LINE_SPACES_6 = "\n\n\n\n\n\n"
  LINE_TYPE_A = "     -----------------------------------------------"
  LINE_TYPE_B = "     |                                             |"
  RESULT_LINE = 
    "     | turn 12                                     |
     | turn 11                                     |
     | turn 10                                     |
     | turn 09                                     |
     | turn 08                                     |
     | turn 07                                     |
     | turn 06                                     |
     | turn 05                                     |
     | turn 04                                     |
     | turn 03                                     |
     | turn 02                                     |
     | turn 01                                     |"
      
  def choose_mode(input)
    if input == 1
      puts "\n          MASTERMIND(User Version)", 
           "* A set of 5 colors was picked in random",
           "* To win this game, you must guess what these colors are",
           "  and their proper arrangement within 12 turns",
           "* You will type-in 5 out of 7 of these characters",
           "  Ex. roygb",
           DEF_COLORS
    elsif input == 2
      puts "\n          MASTERMIND(Computer Version)",
           "* You will choose 5 colors from a set of 7",
           "* Then set the AI's intelligence level",
           "* Let's see if the computer can guess the secret colors",
           "  you set within 12 turns",
           "* The following are the colors to choose from:",
           "\n",
           COLOR_HASH.values
    else
      puts "Please input 1 or 2 then hit Enter in your keyboard"
      choose_mode(gets.chomp!.to_i)
    end
  end
end
      
class Mastermind
  include Game
  attr_reader :input, :mode1_colors, :mode2_colors, :ai_intelligence
  
  def initialize(input)
    @input = input
    choose_mode(input)
  end  
  
  def start()
    @input == 1 ? mode1_preferences : mode2_preferences
  end  
  
  private
  def mode1_preferences
    @mode1_colors = COLOR_PERMUTATIONS[rand(COLOR_PERMUTATIONS.count)].join
  end  
  
  def mode2_preferences
    @mode2_colors = []
    $ai_int = 0
    
    puts "Please set the AI's intelligence level",
         "Pick from numbers 1-5"
    $ai_int = gets.chomp!.to_i until $ai_int.between?(1,5)
    @ai_intelligence = $ai_int      
   
    5.times do |x|
      puts "Please set color #{x+1}"
        choice = gets.chomp!.capitalize
        (COLOR_HASH.values.include? choice) && (@mode2_colors.none? choice) ? 
          @mode2_colors.push(choice) : redo
    end
  end

  def self.game_results(mode, game_won, turns, sec_color)
    if mode == 1
      if game_won == true
        return "Congratulations!, you have guessed the secret colors in #{turns} turns"
      else
        return "GAME OVER: the secret code is (#{sec_color})"
      end
    elsif mode == 2
      if game_won == true
        return "Game Over: AI level #{$ai_int} cracked your code in #{turns} turns"
      else
        return "GAME OVER: AI level #{$ai_int} wasn't able to crack your code"
      end
    end
  end
end
    
class User
  include Game
  attr_reader :secret_color, :turn_count
  
  def initialize(secret_color)
    @secret_color = secret_color
  end

  def self.game_won
    @@game_won
  end
  
  def guess(count)
    @turn_count = count
    puts "Turn #{count}: Please choose 5 colors:"
  end
  
  def check_guess(guess, count)
    $guess = guess.split('')
    if COLOR_PERMUTATIONS.include? $guess
      User.create_display(@secret_color, guess, count)
    else
      show_error(guess, count)
    end
  end

  def show_error(guess, count)
    if guess.length != 5
      puts guess.length < 5 ? 
        "You input #{guess.length} (requires 5 characters)" :
        "You input #{guess.length} (put exactly 5 characters)"
    elsif $guess.uniq.length != $guess.length
      dups = $guess.group_by{|e| e}.keep_if{|_, e| e.length > 1}
      dups.keys.each {|d| puts "#{d} -> duplicated!"}
    elsif COLOR_PERMUTATIONS.none? $guess
      puts '', 'Invalid characters:'
      $guess.each do |x|
        puts ("roygbiv".split('').none? x) ? "#{x} -> invalid!" : "#{x} -> ok"
      end
    end
      puts '', "Please re-type" 
      check_guess(gets.chomp!, count)
  end

  def self.create_display(given, guess, count)
    @@game_won = (guess == given) ? true : false
    
    a, b, c, d = [], [], [], []
    5.times do |x|
      if given.split('').include? guess[x]
        given[x] == guess[x] ? a.push('$') : b.push('O')
      elsif given.split('').none? guess[x]
        c.push('?')
      end
    end
    guess.split('').each {|g| d.push(COLOR_HASH[:"#{g}"])}
    
    @displayC = a + b + c
    @@ommited = COLOR_KEYS -  guess.split('')
    @line2 = "turn #{count}"
    @line3 = d.join(' ').upcase!
    @line4 = "#{@displayC.count('O') + @displayC.count('$') }/5 guessed colors"
    @line5 = "#{@displayC.count('$')} correct positions"
    @update_line = create_update_line(guess, count, @@ommited, @displayC.join(' ') )
    show_result
  end
  
  def self.create_update_line(guess, count, ommited, prog_display)
    a = "| turn 0#{count}         #{guess} | #{ommited.join('')}       #{prog_display}  |" 
    b = "| turn #{count}         #{guess} | #{ommited.join('')}       #{prog_display}  |"
    count.to_s.length == 1 ?
      RESULT_LINE.gsub!("| turn 0#{count}                                     |", a) :
      RESULT_LINE.gsub!("| turn #{count}                                     |", b) 
  end
  
  def self.show_result
    puts LINE_TYPE_A,
    trim_display(@line2),
    trim_display(@line3),
    trim_display(@line4),
    trim_display(@line5),
    LINE_TYPE_B,
    LINE_TYPE_B,
    RESULT_LINE,
    LINE_TYPE_A,
    LINE_SPACES_6
  end

  def self.trim_display(input)
    allowance = 45 - input.length
    ratio = allowance / 2
    
    a, b = ["     |"], ["|"]
    ratio.times do |x|
      a.push(" ")
      b.push(" ")
    end
 
    (allowance.odd?) ?  b.push(" ") : ''
    return(a.join + input + b.reverse.join)
  end
end
    
class AI < User
  include Game
  attr_reader :intelligence, :secret_color
  
  def initialize(secret_color, intelligence)
    @secret_color = secret_color
    @intelligence = intelligence
    AI.start(secret_color, intelligence)
  end

  def self.start(sec_col, int)
    puts LINE_SPACES_6,
         "You set the colors -> \"#{sec_col.join(', ')}\"",
         LINE_SPACES_2,
         "Do you want the A.I. with a level #{int} intelligence to start it's guessing?",
         LINE_SPACES_2,
         "                       Please press enter"
    puts LINE_SPACES_6 if gets == "\n"
  end

  def self.initial_set(int, secret_color, guess_count)
    x = COLOR_HASH.values.permutation(5).to_a
    first_guess = x[rand(x.count)]
    $guess_count = guess_count
    $int_level = int * 30
    $sec_color = AI.abbreviate(secret_color)
    $first_guess = AI.abbreviate(first_guess)
    AI.check_guess($sec_color, $first_guess, $guess_count)
  end
  
  def self.check_guess(sec_col, guess, count)
    guess = guess.split('')
    $prev_guess = guess
    if COLOR_PERMUTATIONS.include? guess
      User.create_display(sec_col, guess.join(''), count)
    else
      show_error(guess, count)
    end
  end
  
  def prev_attr
    [$sec_color, $prev_guess, $int_level, @@ommited, $turn_count]
  end
  
  def self.next_guess(secret_col, last_guess, int, ommited, guess_count)
    $used = []
    scores = []
    intel = int * guess_count
    $turn_count = guess_count
    puts LINE_SPACES_2, "Press enter for guess ##{guess_count}"
    if gets == "\n"
       user = secret_col.split('')
       ai = last_guess + ommited
       $used.push(last_guess - ommited)
       ai_guesses = ai.permutation(5).to_a
      
       int_range = ai_guesses[0..intel] - $used
       int_range.each {|x| scores.push(AI.check_progress(user, x))}
       new_guess = int_range[scores.index(scores.max)].join('')
       AI.check_guess(secret_col, new_guess, guess_count)
    end
  end

  def self.abbreviate(input)
    a = []
    input.each {|x| a.push(x[0].downcase)}
    return(a.join)
  end

  def self.check_progress(given, guess)
    a, b = 0, 0
    5.times do |x|
      a += (given.include? guess[x]) ? 20 : 0
      b += (given[x] == guess[x]) ? 20 : 0
    end
    return((a+b) / 2)
  end
end
      
puts "Welcome to Mastermind Game," \
      " who's gonna play?
      1.User
      2.Computer"
game = Mastermind.new(gets.chomp!.to_i)

puts  "\n            START? press ENTER"
game.start() if gets == "\n"

if game.input == 1
  mode1 = User.new(game.mode1_colors)
  12.times do |x|
    mode1.guess(x+1)
    mode1.check_guess(gets.chomp!, x+1)
    break if User.game_won
  end
    Mastermind.game_results(1, User.game_won, mode1.turn_count, mode1.mode1_colors)
elsif game.input == 2
  mode2 = AI.new(game.mode2_colors, game.ai_intelligence)
  first_guess = AI.initial_set(mode2.intelligence, mode2.secret_color, 1)
  11.times  do |x|
    AI.next_guess(mode2.prev_attr[0],
                  mode2.prev_attr[1],
                  mode2.prev_attr[2],
                  mode2.prev_attr[3],
                  x+2)
    break if AI.game_won
  end
    Mastermind.game_results(2, AI.game_won, mode2.prev_attr[4], mode2.secret_color)
end