require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require_relative 'game'

class Game_test < Minitest::Test

  def setup
    @g = Game.new(1, 1, 2)
  end

  
  # UNIT TESTS FOR METHOD print_status(num_rubies, num_fakes, name)
  # Equivalence classes:
  # num_rubies = 0, num_fakes = 0
  # num_rubies = 1, num_fakes = 0
  # num_rubies = 0, num_fakes = 1
  # num_rubies = 1, num_fakes = 1
  # num_rubies > 1, num_fakes > 1

  #if num_rubies = 0 and num_fakes = 0, print out message with correct grammar
  def test_print_status_zeroes
	assert_output("\tFound no rubies or fake rubies in Enumerated Canyon\n") {@g.print_status(0,0,"Enumerated Canyon")}
  end
  
  #if num_rubies = 1 and num_fakes = 0, print out message with correct grammar
  def test_print_status_one_ruby
	assert_output("\tFound 1 ruby and 0 fake rubies in Enumerated Canyon\n") {@g.print_status(1,0,"Enumerated Canyon")}
  end
  
  #if num_rubies = 0 and num_fakes = 1, print out message with correct grammar
  def test_print_status_one_fake
	assert_output("\tFound 0 rubies and 1 fake ruby in Enumerated Canyon\n") {@g.print_status(0,1,"Enumerated Canyon")}
  end
  
  #if num_rubies = 1 and num_fakes = 1, print out message with correct grammar
  def test_print_status_one_each
	assert_output("\tFound 1 ruby and 1 fake ruby in Enumerated Canyon\n") {@g.print_status(1,1,"Enumerated Canyon")}
  end
  
  #if num_rubies > 1 and num_fakes > 1, print out message with correct grammar
  def test_print_status_multiples
	assert_output("\tFound 2 rubies and 3 fake rubies in Enumerated Canyon\n") {@g.print_status(2,3,"Enumerated Canyon")}
  end
  
  #if num_rubies and num_fakes are negative values, should raise an exception
  #EDGE CASE
  def test_print_status_multiples
	assert_raises("ERROR: Cannot have a negative number of rubies or fake_rubies.\n") {@g.print_status(-2,-3,"Enumerated Canyon")}
  end  
  
  # UNIT TESTS FOR METHOD print_results(num_rubies, num_fakes, prospector_num, num_days)
  # Equivalence classes:
  # num_days = 1
  # num_days = 2
  # num_days = 200
  
  #if num_rubies = 1, print out message with correct grammar
  def test_print_results_one_day
	assert_output("After 1 day, Rubyist #2 found:\n\t4 rubies.\n\t5 fake rubies.\n") {@g.print_results(4, 5, 2, 1)}
  end
  
  #if num_rubies = 2, print out message with correct grammar
  def test_print_results_two_days
	assert_output("After 2 days, Rubyist #2 found:\n\t4 rubies.\n\t5 fake rubies.\n") {@g.print_results(4, 5, 2, 2)}
  end
  
  #if num_rubies = 200, print out message with correct grammar
  #EDGE CASE
  def test_print_results_many_days
	assert_output("After 200 days, Rubyist #2 found:\n\t4 rubies.\n\t5 fake rubies.\n") {@g.print_results(4, 5, 2, 200)}
  end
  
  # UNIT TESTS FOR METHOD leaving_message(num_rubies)
  # Equivalence classes:
  # num_rubies >= 11
  # 1 <= num_rubies <= 10 
  # num_rubies == 0
  
  #if num_rubies = 11, print out victorious message
  def test_leaving_message_victorious
	assert_output("Going home victorious!\n") {@g.leaving_message(11)}
  end
  
  #if num_rubies is between 1 and 10, print out sad message
  def test_leaving_message_sad
	assert_output("Going home sad.\n") {@g.leaving_message(1)}
  end
  
  #if num_rubies == 0, print out empty-handed message
  def test_leaving_message_empty
	assert_output("Going home empty-handed.\n") {@g.leaving_message(0)}
  end
  
  #if num_rubies < 0, raises an exception
  def test_leaving_message_empty
	assert_raises("ERROR: Cannot have a negative number of rubies.\n") {@g.leaving_message(-5)}
  end
  
  
  # UNIT TESTS FOR METHOD simulate_turn(prospector, max_rubies, max_fake_rubies, name, prng)
  # Equivalence classes:
  # rubies, fake_rubies = 2, 0
  
  #if a prospector finds 2 total rubies, then the simulate_turn method returns 2
  def test_simulate_turn
	mocked_prospector = Minitest::Mock.new("mocked prospector")
	mocked_prng = Minitest::Mock.new("mocked prng")
	def mocked_prospector.prospector_go(rub, fake, mocked_prng); [2,0]; end
	assert_equal @g.simulate_turn(mocked_prospector, 5, 0, "Nil Town", mocked_prng), 2
  end  
end


 