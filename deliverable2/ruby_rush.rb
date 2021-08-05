# David Stropkey
# Deliverable #2  -- Ruby Rush main file

require_relative 'game.rb'

seed = ARGV[0].to_i
prospectors = ARGV[1].to_i
turns = ARGV[2].to_i

raise "\nUsage:\nruby ruby_rush.rb *seed* *num_prospectors* *num_turns*"\
      "\n*seed* should be an integer"\
      "\n*num_prospectors* should be a non-negative integer"\
      "\n*num_turns* should be a non-negative integer" unless ARGV.count == 3 && seed.class == Integer &&
                                                              prospectors.class == Integer && prospectors >= 0 &&
                                                              turns.class == Integer && turns >= 0
ruby_rush_game = Game.new(seed, prospectors, turns) # create a new Ruby Rush game

ruby_rush_game.start # start the game
