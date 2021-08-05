require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require_relative 'verifier_checker'

class All_tests < Minitest::Test

  def setup
    hashes = Hash[*File.read('stored_char_hashes.txt').split(/[, \n]+/)]

    hashes.each do |key, value|
      hashes[key] = value.to_i
    end
  
    @v = VerifierChecker.new("0|0|SYSTEM>281974(100)|1553188611.560418000|6283", hashes)
    @participants = {}
  end

  # test that printed output is what is should be with normal input
  def test_print_accounts_happy
    samples = {}
    samples["123456"] = "100"
    samples["234567"] = "50"
    samples["987654"] = "10"
    output = @v.print_accounts(samples)
	  assert_nil output
  end

  # test that printed output is empty with no input
  def test_print_accounts_empty
    samples = {}
    output = @v.print_accounts(samples)
	  assert_nil output
  end

  def test_verify_block_num_zero
    output = @v.verify_block_num('2', 0)
    assert_equal "Line 0: Error: The first block must be numbered 0\nBLOCKCHAIN INVALID", output
  end

  def test_verify_block_num_happy
    output = @v.verify_block_num('2', 2)
    assert_nil output
  end

  def test_verify_block_num_not_empty
    output = @v.verify_block_num("", 0)
    assert_equal output, "Line 0: Format of block number not valid. Cannot be empty\nBLOCKCHAIN INVALID"
  end

  def test_verify_block_num_mismatch
    output = @v.verify_block_num('2', 4)
    assert_equal "Line 4: Invalid block number 2, should be 4\nBLOCKCHAIN INVALID", output
  end

  def test_verify_block_num_non_integer
    output = @v.verify_block_num('bad_num', 4)
    assert_equal "Line 4: Invalid block number bad_num, must be an integer\nBLOCKCHAIN INVALID", output
  end

  def test_verify_block_format_happy
    output = @v.verify_block_format(["0","0","SYSTEM>281974(100)","1553188611.560418000","6283"], 0)
    assert_nil output
  end

  def test_verify_block_format_too_few
    output = @v.verify_block_format("0|0|SYSTEM>281974(100)|1553188611.560418000", 0)
    assert_equal output, "Line 0: Format of block not valid. Must have 5 segments separated by |'s\nBLOCKCHAIN INVALID"
  end

  def test_verify_block_format_not_empty
    output = @v.verify_block_format("", 0)
    assert_equal output, "Line 0: Format of block not valid. Cannot be empty\nBLOCKCHAIN INVALID"
  end

  def test_verify_block_format_too_many
    output = @v.verify_block_format('0|0|SYSTEM>281974(100)|1553188611.560418000|6283|6543', 0)
    assert_equal output, "Line 0: Format of block not valid. Must have 5 segments separated by |'s\nBLOCKCHAIN INVALID"
  end

  def test_verify_prev_hash_happy
    output = @v.verify_previous_hash('d120', 'd120', 4)
    assert_nil output
  end

  def test_verify_prev_hash_non_zero_start
    output = @v.verify_previous_hash('0d12', '0d12', 4)
    assert_equal output, "Line 4: Previous hash segment starts with a 0\nBLOCKCHAIN INVALID"
  end

  def test_verify_prev_hash_non_alpha
    output = @v.verify_previous_hash('d12;', 'd12;', 4)
    assert_equal output, "Line 4: Format of previous hash segment not valid. Must be alphanumeric\nBLOCKCHAIN INVALID"
  end

  def test_verify_prev_hash_too_big
    output = @v.verify_previous_hash('d120dj', 'd120dj', 4)
    assert_equal output, "Line 4: Format of previous hash segment not valid. Must be under 4 length\nBLOCKCHAIN INVALID"
  end

  def test_verify_prev_hash_too_small
    output = @v.verify_previous_hash('', '', 4)
    assert_equal output, "Line 4: Format of previous hash segment not valid. Must be at least 1 char\nBLOCKCHAIN INVALID"
  end

  def test_verify_prev_hash_mismatch
    output = @v.verify_previous_hash('d120', 'd23f', 4)
    assert_equal output, "Line 4: Previous hash segment is d120, should be d23f\nBLOCKCHAIN INVALID"
    
  end

  def test_verify_transaction_not_empty
      output = @v.verify_transactions("", @participants, 0)
      assert_equal output, "Line 0: Format of transactions segment not valid. Cannot be empty\nBLOCKCHAIN INVALID"
  end
  
  def test_verify_transactions_happy
    @participants['281974'] = 20
    output = @v.verify_transactions("281974>758620(10):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", @participants, 3)
    assert_nil output
  end

  def test_verify_transactions_system_not_last
    output = @v.verify_transactions("281974>758620(10):281974>495699(4)495699>357621(1):123456>268241(100)", "495699=>20", 3)
    assert_equal output, "Line 3: Invalid transaction. SYSTEM must be the last sender.\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_no_parenthesis
    output = @v.verify_transactions("281974>75862010:281974>495699(4):495699>357621(1):SYSTEM>268241(100)", "495699=>20", 3)
    assert_equal output, "Line 3: Could not parse transaction 281974>75862010. Format: ######>######(#)\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_invalid_coins
    output = @v.verify_transactions("281974>758620(invalid):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", "495699=>20", 3)
    assert_equal output, "Line 3: Could not parse transaction 281974>758620(invalid). Format: ######>######(#)\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_too_many_participants
    output = @v.verify_transactions("281974>758620>345621(10):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", "495699=>20", 3)
    assert_equal output, "Line 3: Invalid transaction. Must have only 2 participants per transaction.\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_too_few_participants
    output = @v.verify_transactions("281974(10):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", "495699=>20", 3)
    assert_equal output, "Line 3: Invalid transaction. Must have only 2 participants per transaction.\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_bad_account_nums_too_long
    output = @v.verify_transactions("28197214>758620(10):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", "495699=>20", 3)
    assert_equal output, "Line 3: Sender account number is not 6 digits\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_bad_account_nums_too_short
    @participants["495699"] = 20
    output = @v.verify_transactions("2819>758620(10):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", @participants, 3)
    assert_equal output, "Line 3: Sender account number is not 6 digits\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_bad_account_nums_non_int
    @participants["495699"] = 20
    output = @v.verify_transactions("David>758620(10):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", @participants, 3)
    assert_equal output, "Line 3: Sender account number is not 6 digits\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_negative_coins
    @participants["495699"] = 20
    output = @v.verify_transactions("281974>758620(-10):281974>495699(4):495699>357621(1):SYSTEM>268241(100)", @participants, 3)
    assert_equal output, "Line 3: Could not parse transaction 281974>758620(-10). Format: ######>######(#)\nBLOCKCHAIN INVALID"
  end

  def test_verify_transactions_negative_accounts
    @participants["495699"] = 0
    output = @v.verify_transactions("281974>758620(10):281974>495699(4):495699>357621(10):SYSTEM>268241(100)", @participants, 3)
    assert_equal output, "Line 3: Invalid block, address 495699 has -6 billcoins!\nBLOCKCHAIN INVALID"
  end

  def test_verify_timestamp_happy
    output = @v.verify_time_stamp('1553188611.562586000', '1553188611.560418000', 2)
    assert_nil output
  end

  def test_verify_timestamp_not_empty
      output = @v.verify_time_stamp("", "1553188611.562586000", 0)
      assert_equal output, "Line 0: Format of timestamp not valid. Cannot be empty\nBLOCKCHAIN INVALID"
  end
  
  def test_verify_seconds_not_empty
      output = @v.verify_time_stamp(".100", "1553188611.562586000", 0)
      assert_equal output, "Line 0: Timestamp cannot be empty on left side of the '.'\nBLOCKCHAIN INVALID"
  end

  def test_verify_microseconds_not_empty
      output = @v.verify_time_stamp("1201349234343.", "1553188611.562586000", 0)
      assert_equal output, "Line 0: Timestamp cannot be empty on right side of the '.'\nBLOCKCHAIN INVALID"
  end

  def test_verify_timestamp_bad_micros
    output = @v.verify_time_stamp('1553188611.562586000', '1553188611.660418000', 2)
    assert_equal output, "Line 2: Previous timestamp 1553188611.660418000 >= new time_stamp 1553188611.562586000\nBLOCKCHAIN INVALID"
  end

  def test_verify_bad_seconds
    output = @v.verify_time_stamp('1553188611.562586000', '2553188611.560418000', 2)
    assert_equal output, "Line 2: Previous timestamp 2553188611.560418000 >= new time_stamp 1553188611.562586000\nBLOCKCHAIN INVALID"
  end

  def test_verify_timestamp_non_integer_seconds
    output = @v.verify_time_stamp('a553188611.562586000', '1553188611.560418000', 2)
    assert_equal output, "Line 2: Seconds segment not an integer\nBLOCKCHAIN INVALID"
  end

  def test_verify_timestamp_non_integer_micros
    output = @v.verify_time_stamp('1553188611.a62586000', '1553188611.560418000', 2)
    assert_equal output, "Line 2: Microseconds segment not an integer\nBLOCKCHAIN INVALID"
  end

  def test_verify_block_hash_happy
    def @v.calc_hash(value); 'd80e'; end 
    output = @v.verify_block_hash('d80e', "6|10a9|SYSTEM>338967(100)|1553184699.677339000", 6)
    assert_nil output
  end

  def test_verify_block_hash_not_empty
    output = @v.verify_block_hash("", "6|10a9|SYSTEM>338967(100)|1553184699.677339000", 6)
    assert_equal output, "Line 6: Format of block hash not valid. Cannot be empty\nBLOCKCHAIN INVALID"
  end

  def test_verify_block_hash_leading_zero
    output = @v.verify_block_hash('080e', "6|10a9|SYSTEM>338967(100)|1553184699.677339000", 6)
    assert_equal output, "Line 6: Block hash segment starts with a 0\nBLOCKCHAIN INVALID"
  end  

  def test_verify_block_hash_bad_format
    output = @v.verify_block_hash('d?0e', "6|10a9|SYSTEM>338967(100)|1553184699.677339000", 6)
    assert_equal output, "Line 6: Block hash segment not alphanumeric\nBLOCKCHAIN INVALID"\
  end

  def test_verify_block_hash_too_long
    output = @v.verify_block_hash('d80ee', "6|10a9|SYSTEM>338967(100)|1553184699.677339000", 6)
    assert_equal output, "Line 6: Block hashs segment exceeds 4 characters long\nBLOCKCHAIN INVALID"
  end

  def test_verify_calc_hash_happy
    output = @v.calc_hash("6|10a9|SYSTEM>338967(100)|1553184699.677339000")
    assert_equal output, 'd80e'
  end
  
  def verify_block_hash_mismatch
    def @v.calc_hash(value); 'd80f'; end 
    output = verify_block_hash('d80e', "6|10a9|SYSTEM>338967(100)|1553184699.677339000", 6)
    assert_equal output, "Line 6: Hash set to d80e, should be d80f\nBLOCKCHAIN INVALID"
  end
end
  