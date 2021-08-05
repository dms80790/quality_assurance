# David Stropkey
require_relative 'town.rb'
require_relative 'prospector.rb'
# class that holds game information and runs an instance of the game
class Game
  attr_reader :towns

  def initialize(seed, prospectors, turns)
    @seed = seed # seed used for pseudo-random number generator
    @num_prospectors = prospectors
    @num_turns = turns # a turn is used up when 0 fake or real rubies found
  end

  def start
    # create a psuedo random number generator
    prng = Random.new(@seed)

    # initialize the towns array with town info
    @towns = []
    @towns[0] = Town.new('Enumerable Canyon', 1, 1, [1, 2])
    @towns[1] = Town.new('Duck Type Beach', 2, 2, [0, 4])
    @towns[2] = Town.new('Monkey Patch City', 1, 1, [0, 3, 4])
    @towns[3] = Town.new('Nil Town', 0, 3, [2, 5])
    @towns[4] = Town.new('Matzburg', 3, 0, [1, 2, 5, 6])
    @towns[5] = Town.new('Hash Crossing', 2, 2, [3, 4, 6])
    @towns[6] = Town.new('Dynamic Palisades', 2, 2, [4, 5])

    prospector_num = 1
    while @num_prospectors > 0
      prospector, num_days = simulate_prospector(prospector_num, prng)

      print_results(prospector.total_rubies, prospector.total_fake_rubies, prospector_num, num_days)
      leaving_message(prospector.total_rubies)
      @num_prospectors -= 1 # decrement the number of prospectors
      prospector_num += 1 # next index
    end
  end

  def simulate_prospector(prospector_num, prng)
    current_town = @towns[0] # every prospector starts at Enumerable Canyon
    prospector = Prospector.new # create a new prospector
    prospector_turns = @num_turns
    puts "Rubyist ##{prospector_num} starting in #{current_town.name}"
    num_days = 0
    while prospector_turns > 0
      count = simulate_turn(prospector, current_town.max_rubies, current_town.max_fake_rubies, current_town.name, prng)
      num_days += 1
      if count.zero?
        nxt_town_index = current_town.next(prng)
        nxt_town = @towns[nxt_town_index]
        prospector_turns -= 1

        if prospector_turns > 0
          puts "Heading from #{current_town.name} to #{nxt_town.name}."
          current_town = nxt_town
        end
      end
    end
    [prospector, num_days]
  end

  def simulate_turn(prospector, max_rubies, max_fake_rubies, name, prng)
    # simulate a turn and get results
    num_rubies, num_fakes = prospector.prospector_go(max_rubies, max_fake_rubies, prng)
    print_status(num_rubies, num_fakes, name) # print how many rubies and fakes were found this turn

    num_rubies + num_fakes
  end

  def print_status(num_rubies, num_fakes, name)
    raise "ERROR: Cannot have a negative number of rubies or fake_rubies.\n" if num_rubies < 0 || num_fakes < 0

    if num_rubies.zero? && num_fakes.zero?
      puts "\tFound no rubies or fake rubies in #{name}"
    elsif num_rubies == 1 && num_fakes == 1
      puts "\tFound #{num_rubies} ruby and #{num_fakes} fake ruby"\
      " in #{name}"
    elsif num_rubies == 1 && num_fakes != 1
      puts "\tFound #{num_rubies} ruby and #{num_fakes} fake rubies"\
      " in #{name}"
    elsif num_rubies != 1 && num_fakes == 1
      puts "\tFound #{num_rubies} rubies and #{num_fakes} fake ruby"\
      " in #{name}"
    else
      puts "\tFound #{num_rubies} rubies and #{num_fakes} fake rubies"\
      " in #{name}"
    end
  end

  def print_results(num_rubies, num_fakes, prospector_num, num_days)
    if num_days == 1
      puts "After #{num_days} day, Rubyist ##{prospector_num} found:"
    else
      puts "After #{num_days} days, Rubyist ##{prospector_num} found:"
    end

    puts "\t#{num_rubies} rubies."
    puts "\t#{num_fakes} fake rubies."
  end

  def leaving_message(num_rubies)
    raise "ERROR: Cannot have a negative number of rubies.\n" if num_rubies < 0

    if num_rubies > 10
      puts 'Going home victorious!'
    elsif num_rubies > 0
      puts 'Going home sad.'
    else
      puts 'Going home empty-handed.'
    end
  end
end
