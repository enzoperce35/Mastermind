module Game
  INPUT_PATTERN1 = "\nr = red      o = orange     y = yellow",
                   "g = green      b = blue ",
                   "i = indigo     v = violet\n"
  INPUT_PATTERN2 = {:r => 'Red', :o => 'Orange', :y => 'Yellow',
                    :g => 'Green', :b => 'Blue', :i => 'Indigo',
                    :v => 'Violet'}
  COLOR_KEYS = ['r', 'o', 'y', 'g', 'b', 'i', 'v']
  COLOR_PERMUTATIONS = 'roygbiv'.split('').permutation(5).to_a
  NEW_SPACES_2 = "\n\n"
  NEW_SPACES_6 = "\n\n\n\n\n\n"
  LINE_SPACES_12 = "            "
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

  class Mastermind
    attr_reader :mode, :secret_colors, :ai_intelligence
    
    def initialize
      @mode = 0
      @ai_intelligence = ''
    end
    
    def start
      puts 'Welcome to Mastermind Game.'\
            ' Who\'s gonna play?',
            '  1.User',
            '  2.Computer'
      @mode = gets.chomp!.to_i until @mode == 1 || @mode == 2
      @secret_colors = initiate(@mode)
    end

    def initiate(mode)
      if mode == 1
        UserMode.intro
        UserMode.secret_colors
      else
        CompMode.intro
        @ai_intelligence = CompMode.ai_intelligence
        CompMode.secret_colors
      end
    end

    def self.check_guess(guess, guess_count, sec_col)
      guess = guess.split('')
      guess_res = COLOR_KEYS - guess
      if COLOR_PERMUTATIONS.include? guess
        stats_disp = Display.status(sec_col, guess, guess_count)
        updte_disp = Display.upd_line(guess, guess_count, guess_res, stats_disp)
        line2_disp = Display.line2(guess_count)
        line3_disp = Display.line3(guess)
        line4_disp = Display.line4(stats_disp)
        line5_disp = Display.line5(stats_disp)
        Display.show_display(line2_disp, line3_disp, line4_disp, line5_disp)
      else
        UserMode.show_error(guess, guess_count, sec_col)
      end

    def result(mode, game_won, turns, sec_color)
      result = ''
      if mode == 1
        result = game_won ? 
          "Congratulations!, you have guessed the secret colors in #{turns} turns" :
          "GAME OVER: the secret code is (#{sec_color})"
      else
        result = game_won ?
           "Game Over: AI level #{@ai_intelligence} cracked your code in #{turns} turns" :
           "GAME OVER: AI level #{@ai_intelligence} wasn't able to crack your code"
      end
      result
    end
  end

    class Display
      def self.status(sec_col, guess, guess_cnt)
        a, b, c = [], [], []
        5.times do |x|
          if sec_col.split('').include? guess[x]
            sec_col[x] == guess[x] ? a.push('$') : b.push('O')
          elsif sec_col.split('').none? guess[x]
            c.push('?')
          end
        end
        (a + b + c).join(' ')
      end

      def self.line2(guess_count)
        turn_disp = "turn #{guess_count}"
        Display.trim_display(turn_disp)
      end

      def self.line3(guess)
        colors = []
        guess.each {|g| colors.push(INPUT_PATTERN2[:"#{g}"])}
        colors_disp = colors.join(' ').upcase!
        Display.trim_display(colors_disp)
      end

      def self.line4(game_status)
        cor_col = "#{game_status.count('O') + game_status.count('$') }/5 guessed colors"
        Display.trim_display(cor_col)
      end

      def self.line5(game_status)
        cor_pos = "#{game_status.count('$')} correct positions"
        Display.trim_display(cor_pos)
      end

      def self.upd_line(guess, count, reserves, status)
        a = "| turn 0#{count}         #{guess.join} | #{reserves.join('')}       #{status}  |" 
        b = "| turn #{count}         #{guess.join} | #{reserves.join('')}       #{status}  |"
        count.to_s.length == 1 ?
          RESULT_LINE.gsub!("| turn 0#{count}                                     |", a) :
          RESULT_LINE.gsub!("| turn #{count}                                     |", b) 
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
        a.join + input + b.reverse.join
      end

      def self.show_display(line2, line3, line4, line5)
        puts NEW_SPACES_6, LINE_TYPE_A,
             line2, line3, line4, line5,
             LINE_TYPE_B, LINE_TYPE_B,
             RESULT_LINE,
             LINE_TYPE_A,
             NEW_SPACES_6
      end
    end
  end

  class Error
    def self.char_count_err(guess)
      puts guess.length < 5 ? 
        "You input #{guess.length} (requires 5 characters)" :
        "You input #{guess.length} (put exactly 5 characters)"
    end

    def self.duplication_err(guess)
      dups = guess.group_by{|e| e}.keep_if{|_, e| e.length > 1}
      dups.keys.each {|d| puts "#{d} -> duplicated!"}
    end

    def self.char_error(guess)
      puts '', 'Invalid characters:'
      guess.each do |x|
        puts ("roygbiv".split('').none? x) ? "#{x} -> invalid!" : "#{x} -> ok"
      end
    end
  end
  
  class UserMode
    def self.intro
      puts "\n          MASTERMIND(User Version)", 
           "* A set of 5 colors was picked in random",
           "* To win this game, you must guess what these colors are",
           "  and their proper arrangement within 12 turns",
           "* You will type-in 5 out of 7 of these characters",
           "  Ex. roygb",
           INPUT_PATTERN1, NEW_SPACES_2, LINE_SPACES_12 << "START? press ENTER"
           return nil unless gets == "\n"
    end

    def self.secret_colors
      puts 'Secret colors was set, try to guess it within 12 turns',
      'Good luck!', NEW_SPACES_6
      COLOR_PERMUTATIONS[rand(COLOR_PERMUTATIONS.count)].join
    end

    def self.show_error(guess, guess_count, sec_col)
      if guess.length != 5
        Error.char_count_err(guess)
      elsif guess.uniq.length != guess.length
        Error.duplication_err(guess)
      elsif COLOR_PERMUTATIONS.none? guess
        Error.char_error(guess)
      end
        puts '', "Please re-type" 
        Mastermind.check_guess(gets.chomp!, guess_count, sec_col)
    end
  end

  class CompMode
    def self.intro
      puts "\n          MASTERMIND(Computer Version)",
           "* You will choose 5 colors from a set of 7",
           "* Then set the AI's intelligence level",
           "* Let's see if the computer can guess the secret colors",
           "  you set within 12 turns",
           "* The following are the colors to choose from:",
           "\n",
      INPUT_PATTERN2.values, NEW_SPACES_2, LINE_SPACES_12 << "START? press ENTER"
      return nil unless gets == "\n"
    end

    def self.ai_intelligence
      ai_intel = 0
      puts "Please set the AI's intelligence level",
           "Pick from numbers 1-5"
      ai_intel = gets.chomp!.to_i until ai_intel.between?(1,5)
      ai_intel
    end

    def self.secret_colors
      sec_col = []
      5.times do |x|
        puts "Please set color #{x+1}"
        choice = gets.chomp!.capitalize
        (INPUT_PATTERN2.values.include? choice) && (sec_col.none? choice) ? 
        sec_col.push(choice) : redo
      end
      sec_col
    end

    def self.start(secret_colors, ai_intelligence)
      puts NEW_SPACES_6,
           "You set the colors -> \"#{secret_colors.join(', ')}\"",
           NEW_SPACES_2,
           "Do you want the A.I. with a level #{ai_intelligence} intelligence to start guessing?",
           NEW_SPACES_2,
           "                       Please press enter"
      puts NEW_SPACES_6 if gets == "\n"
    end

    def first_guess
      permutation = INPUT_PATTERN2.values.permutation(5).to_a
      first_guess = permutation[rand(permutation.count)]
      @sec_colors = abbreviate(@secret_colors)
      @last_guess = abbreviate(first_guess)
      @prev_guess << @last_guess.split('')
      Mastermind.check_guess(@last_guess, @guess_count, @sec_colors)
    end

    def next_guess
      guess_res = COLOR_KEYS - @last_guess.split('')
      int_range = @ai_intelligence * 25 * @guess_count
      puts NEW_SPACES_2, "Press enter for guess ##{@guess_count}"
      gets until gets == "\n"
         guess = @sec_colors
         color = @last_guess.split('') + guess_res
         permu = color.permutation(5).to_a
         range = permu[0..int_range] - @prev_guess
         new_guess(range, guess, @guess_count)
    end

    def new_guess(range, guess, guess_count)
      scores = []
      range.each { |x| scores.push(check_progress(guess, x)) }
      new_guess = range[scores.index(scores.max)].join('')
      @game_won = (new_guess == guess) ? true : false
      @last_guess = new_guess
      @prev_guess << new_guess.split('')
      Mastermind.check_guess(new_guess, guess_count, @sec_colors)
    end

    def abbreviate(input)
      a = []
      input.each { |x| a.push(x[0].downcase) }
      a.join
    end

    def check_progress(given, guess)
      a, b = 0, 0
      5.times do |x|
        a += (given.include? guess[x]) ? 20 : 0
        b += (given[x] == guess[x]) ? 20 : 0
      end
      (a + b) / 2
    end
  end
end

class User
  include Game
  attr_reader :game_won, :guess_count

  def initialize(secret_colors)
    @secret_colors = secret_colors
    @guess_count = 0
    @game_won = false
  end

  def guess
    @guess_count += 1
    puts "Turn #{@guess_count}: Please choose 5 colors:"
    guess = gets.chomp!
    @game_won = (guess == @secret_colors) ? true : false
    Mastermind.check_guess(guess, @guess_count, @secret_colors)
  end
end

class Comp < Game::CompMode
  include Game
  attr_reader :game_won, :guess_count
  def initialize(secret_colors, ai_intelligence)
    @secret_colors = secret_colors
    @prev_guess = []
    @guess_count = 0
    @game_won = false
    @ai_intelligence = ai_intelligence
    CompMode.start(@secret_colors, @ai_intelligence)
  end

  def guess
    @guess_count += 1
    @guess_count == 1 ? first_guess : next_guess
  end
end

game = Game::Mastermind.new
mode = game.start
secret_colors = game.secret_colors
ai_intelligence = game.ai_intelligence

player = game.mode == 1 ? User.new(secret_colors) : Comp.new(secret_colors, ai_intelligence)
12.times do player.guess
  break if player.game_won
end
game.result(game.mode, player.game_won, player.guess_count, secret_colors)

