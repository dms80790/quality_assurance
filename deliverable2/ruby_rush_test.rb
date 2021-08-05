require 'minitest/autorun'
require_relative 'town'

class ruby_rush_test < Minitest::Test

  def test_towns
    town = Town.new("Pittsburgh", 10, 20, [1,2])
	assert_equal town.name, "Pittsburgh"
  end
end