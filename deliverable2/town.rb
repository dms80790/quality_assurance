# David Stropkey
# class that holds town information, including name, rubies and fake_rubies
class Town
  attr_reader :max_rubies, :max_fake_rubies, :name, :neighbors # holds the max number of discoverable fake rubies

  def initialize(name, max_rubies, max_fake_rubies, neighbors)
    @name = name
    @max_rubies = max_rubies
    @max_fake_rubies = max_fake_rubies
    @neighbors = neighbors
  end

  def next(prng)
    # get a random number from 0 to neighbors.size - 1
    random_index = prng.rand(@neighbors.size)
    @neighbors[random_index]
  end
end
