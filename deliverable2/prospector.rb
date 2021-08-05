# David Stropkey
require_relative 'town'
# class that defines individual prospectors
class Prospector
  attr_reader :total_rubies, :total_fake_rubies

  def initialize
    @total_rubies = 0
    @total_fake_rubies = 0
  end

  def prospector_go(max_rubies, max_fake_rubies, prng)
    num_rubies = if max_rubies > 0
                   prng.rand(max_rubies + 1)
                 else
                   0
                 end

    num_fake_rubies = if max_fake_rubies > 0
                        prng.rand(max_fake_rubies + 1)
                      else
                        0
                      end

    @total_rubies += num_rubies
    @total_fake_rubies += num_fake_rubies
    [num_rubies, num_fake_rubies]
  end
end
