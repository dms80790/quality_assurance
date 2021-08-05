require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require_relative 'prospector'

class Prospector_test < Minitest::Test
  def setup
    @p1 = Prospector.new
  end

  # UNIT TESTS FOR METHOD prospector_go(max_rubies, max_fake_rubies, prng)
  # Equivalence classes:
  # max_rubies = 0
  # max_rubies >0
  
  # tests that the correct number of rubies and fake rubies are returned
  # as well as executing the side effect of updating @total_rubies when the
  # number of rubies and fake rubies passed in are both zero
  def test_prospector_go_zero
    prng_mock = Minitest::Mock.new("mocked prng")
	assert_equal @p1.prospector_go(0, 0, prng_mock), [0, 0]
	assert_equal @p1.total_rubies, 0
  end
  
  # tests that the correct number of rubies and fake rubies are returned
  # as well as executing the side effect of updating @total_fake_rubies when the
  # number of rubies and fake rubies passed in are both above zero and the randomly
  # generated number is 1
  def test_prospector_go_one
    prng_mock = Minitest::Mock.new("mocked prng")
	def prng_mock.rand(value); 1; end
	assert_equal @p1.prospector_go(4,4,prng_mock), [1, 1]
	assert_equal @p1.total_fake_rubies, 1
  end
  
  # tests that the correct number of rubies and fake rubies are returned
  # as well as executing the side effect of updating @total_rubies when the
  # number of rubies and fake rubies passed in are both 75 and a random value 
  # of 50 is generated
  def test_prospector_go_fifty_each
    prng_mock = Minitest::Mock.new("mocked prng")
	def prng_mock.rand(value); 50; end
	assert_equal @p1.prospector_go(75, 75, prng_mock), [50, 50]
	assert_equal @p1.total_rubies, 50
  end
  
  # UNIT TESTS FOR METHOD initialize()
  # Since this is an initialization method and there are no arguments, there
  # are no equivalnce classes
  
  # simple check to make sure initialize is setting the values it is supposed to
  # used for code coverage
  def test_initialize
	assert_equal @p1.total_rubies, 0
	assert_equal @p1.total_fake_rubies, 0
  end
end
