require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require_relative 'town'

class Town_test < Minitest::Test

  # UNIT TESTS FOR METHOD next(prng)
  # Doesn't really make sense to partition, as all that
  # is passed in is a prng. The only thing that causes any
  # variation is the number of neighbors, which affects the
  # range of outcomes of .rand(), but we are not testing that
  # method here
  
  # quick test to make sure that given a certain set of neighbors
  # values and a certain randomly generated number, the correct 
  # value is returned
  def test_next
    t1 = Town.new("Enumerated Canyon", 1, 1, [1, 3])
    prng_mock = Minitest::Mock.new("mocked prng")
	def prng_mock.rand(value); 1; end
	assert_equal t1.next(prng_mock), 3
  end

end