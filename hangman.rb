require "yaml"

class Hangman

  attr_accessor :word, :word_arr, :hidden_word, :all_guesses, :wrong_guesses, :guesses_left

  def initialize
    @word = choose_word
    #makes an array out of the letters of the word to compare guesses to 
    @word_arr = @word.split("")
    #displays player's progress on the word
    @hidden_word = Array.new(@word_arr.length, "_")
    @all_guesses = []
    @wrong_guesses = []
    @guesses_left = 6
  end

  def play_game
    #game ends when player runs out of guesses or player guessed all the letters of the word
    until @guesses_left == 0 || @hidden_word.join == @word
      puts "\n#{@hidden_word.join}\n\nWrong guesses: #{@wrong_guesses.join(", ")}\n\nGuesses left: #{@guesses_left}"
      choice = choose_letter
      check_guess(choice)
      @all_guesses.push(choice)
    end
    #game determines winner based on how many guesses are left
    if @guesses_left != 0
      puts "\nCongratulations! You guessed the word '#{@word}' correctly!\n\n"
      play_again
    else
      puts "\nSorry.. The word was '#{@word}'\n\n"
      play_again
    end
  end

  def choose_word
    dictionary = []
    #takes all words with 5-12 characters and puts it in the dictionary array
    File.open("5desk.txt").readlines.each do |line| 
      if line.length >= 7 && line.length <= 14
        dictionary.push(line.delete("\r\n"))
      end
    end
    #takes a random word from dictionary
    dictionary.sample.downcase
  end

  def choose_letter
    puts "\nChoose a letter! (Enter 'save' to save your game)"
    player_choice = gets.downcase.chomp
    #gives player the option to save every round
    if player_choice == "save"
      save_game
    #player guesses must be: a letter, not a previous guess, and a single character
    elsif player_choice.match?(/\A[a-z]*\z/) && @all_guesses.include?(player_choice) == false && player_choice.length == 1
      player_choice
    #if the guess is in all_guesses, it has already been used
    elsif @all_guesses.include?(player_choice)
      puts "\nYou've already guessed that letter!"
      choose_letter
    #other inputs that are not letters will not be accepted
    else
      puts "\nThat's not a letter!"
      choose_letter
    end
  end

  def check_guess(guess)
    #if word_arr contains the guessed letter, every instance of the letter will be added to hidden_word
    if @word_arr.include?(guess)
      #will continue scanning word_arr for repeats of the same letter
      until @word_arr.include?(guess) == false
        #adds the letter to the same position on hidden_word as it is in word_arr
        @hidden_word[@word_arr.index(guess)] = guess
        #removes the letter from its position in word_arr
        @word_arr[@word_arr.index(guess)] = "_"
      end
    #if word_arr does not contain the letter, the letter is added to wrong_guesses, and guesses_left decreases
    else
      @wrong_guesses.push(guess)
      @guesses_left -= 1
    end
  end
end

def start_game
  puts "\nWelcome to Hangman!"
  puts "Your opponent will come up with a random word,"
  puts "and you have to guess the word by letter!"
  puts "You can get 6 incorrect guesses before you lose."
  puts "Good Luck!"
  #if there is a game_save file, player will receive a prompt to load it
  if File.exists?("game_save.yml")
    load_prompt
  #if there is no game_save file, a new game will start
  else
    game = Hangman.new
    game.play_game
  end
end

def load_prompt
  #prompts the player to load the save_game file or start a new game
  puts "Would you like to load your previous game? (y/n)"
  choice = gets.downcase.chomp
  if choice == "y"
    load_game
  elsif choice == "n"
    game = Hangman.new
    game.play_game
  else
    puts "\nThat's not a valid option!\n"
    load_prompt
  end
end

def save_game
  #serializes currrent game_data values to a yml file and ends the game
  game_data = [@word, @word_arr, @hidden_word, @all_guesses, @wrong_guesses, @guesses_left]
  File.open('game_save.yml', 'w') { |file| file.write(game_data.to_yaml) }
  abort("\nGame Saved!\n\n")
end

def load_game
  #deserializes the yaml file and replaces the current values of game_data with the game_save values
  loaded_game = YAML.safe_load(File.read('game_save.yml'))
  game = Hangman.new
  game.word = loaded_game[0]
  game.word_arr = loaded_game[1]
  game.hidden_word = loaded_game[2]
  game.all_guesses = loaded_game[3]
  game.wrong_guesses = loaded_game[4]
  game.guesses_left = loaded_game[5]
  game.play_game
end

def play_again
  #prompts player to play again
  puts "Would you like to play again? (y/n)"
  choice = gets.downcase.chomp
  if choice == "y"
    start_game
  elsif choice == "n"
    puts "\nSee ya next time!\n\n"
  else
    puts "\nThat's not a valid option!\n\n"
    play_again
  end
end

start_game