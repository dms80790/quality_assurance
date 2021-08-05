# David Stropkey
# CS 1632 Laboon D4
# Spring 2019

# A class that verifies a blockchain
class VerifierChecker
  def initialize(lines, stored_chars)
    @lines = lines # array holding the strings from passed in .txt file
    @stored_chars = stored_chars # dictionary holding calculated hash values
    @block_num = 0 # index variable for block number
    @participants = {} # map to hold participant numbers
    @previous_line_values = []
    @previous_line_values[0] = '0'
    @previous_line_values[1] = '0'
    @previous_line_values[2] = '0'
    @previous_line_values[3] = '0.0'
    @previous_line_values[4] = '0'
  end

  def start
    @lines.each do |line|
      # section each block
      values = line.split('|')
      # block_num 0, previous_hash = 1, transactions = 2, time_stamp = 3, block_hash =4)

      previous_time_stamp = @previous_line_values[3]
      previous_hash_num = @previous_line_values[4]

      # verify the block chain sections
      return verify_block_format(values, @block_num) unless verify_block_format(values, @block_num).nil?
      return verify_block_num(values[0], @block_num) unless verify_block_num(values[0], @block_num).nil?
      return verify_previous_hash(values[1], previous_hash_num, @block_num)\
      unless verify_previous_hash(values[1], previous_hash_num, @block_num).nil?
      return verify_transactions(values[2], @participants, @block_num)\
      unless verify_transactions(values[2], @participants, @block_num).nil?
      return verify_time_stamp(values[3], previous_time_stamp, @block_num)\
      unless verify_time_stamp(values[3], previous_time_stamp, @block_num).nil?
      return verify_block_hash(values[4], "#{values[0]}|#{values[1]}|#{values[2]}|#{values[3]}", @block_num)\
      unless verify_block_hash(values[4], "#{values[0]}|#{values[1]}|#{values[2]}|#{values[3]}", @block_num).nil?

      @previous_line_values = values # set the current line as previous_line
    end
    print_accounts(@participants)
  end

  def verify_block_num(segment, block_num)
    # check to make sure the block num is not empty
    return "Line #{block_num}: Format of block number not valid. Cannot be empty\nBLOCKCHAIN INVALID"\
    if segment.empty?

    # check to see if the first block is 0
    if block_num.zero? && segment.to_i != 0
      return "Line #{block_num}: Error: The first block must be numbered 0\nBLOCKCHAIN INVALID"
    end

    # check to make sure the block number is an integer
    return "Line #{block_num}: Invalid block number #{segment}, must be an integer\nBLOCKCHAIN INVALID"\
    unless segment =~ /^\d*$/

    # check to make sure block numbers are incrementing by one
    if segment.to_i != block_num
      return "Line #{block_num}: Invalid block number #{segment}, should be #{block_num}\nBLOCKCHAIN INVALID"
    end

    nil
  end

  def verify_block_format(values, block_num)
    # check to make sure the block is not empty
    return "Line #{block_num}: Format of block not valid. Cannot be empty\nBLOCKCHAIN INVALID" if values.empty?

    # check to make sure there are 5 segments within a block
    if values.size != 5
      return "Line #{block_num}: Format of block not valid. Must have 5 segments separated by |'s\nBLOCKCHAIN INVALID"
    end

    nil
  end

  def verify_previous_hash(segment, previous_hash_num, block_num)
    # check to make sure the prev_hash segment doesn't start with 0
    return "Line #{block_num}: Previous hash segment starts with a 0\nBLOCKCHAIN INVALID"\
    unless segment[0] != '0' || segment[1].nil?

    # check to make sure the previous hash is alphanumeric
    return "Line #{block_num}: Format of previous hash segment not valid. Must be alphanumeric\nBLOCKCHAIN INVALID"\
    unless segment.match?(/^[a-zA-Z0-9]*$/)

    # check for correct length of previous hash
    if segment.size > 4
      return "Line #{block_num}: Format of previous hash segment not valid. Must be under 4 length\nBLOCKCHAIN INVALID"
    end

    # check to make sure the prev_hash is at least 1 character in length
    return "Line #{block_num}: Format of previous hash segment not valid. Must be at least 1 char\nBLOCKCHAIN INVALID"\
    if segment.empty?

    # check to make sure the previous hash segment matches the previous block's hash value
    return "Line #{block_num}: Previous hash segment is #{segment}, should be #{previous_hash_num}\nBLOCKCHAIN INVALID"\
    unless segment == previous_hash_num

    nil
  end

  def verify_transactions(segment, participants, block_num)
    transactions = segment.split(':') # divide the block into individual transactions

    # check to make sure the transaction block is not empty
    return "Line #{block_num}: Format of transactions segment not valid. Cannot be empty\nBLOCKCHAIN INVALID"\
    if segment.empty?

    # check to make sure the last transaction has SYSTEM as sender
    last_sender = transactions[transactions.size - 1].split('>')[0]

    return "Line #{block_num}: Invalid transaction. SYSTEM must be the last sender.\nBLOCKCHAIN INVALID"\
    unless last_sender.match?(/^SYSTEM$/)

    transactions.each do |line|
      num_coins = line.split(/\((\d*)\)/) # split the transaction into participants and coins

      # check to make sure there are the correct number of values enclosed in parenthesis
      if num_coins.size != 2
        return "Line #{block_num}: Could not parse transaction #{line}. Format: ######>######(#)\n"\
        'BLOCKCHAIN INVALID'
      end

      # check to make sure the number of coins segment is an integer
      return "Line #{block_num}: Number of coins sent is not an integer\nBLOCKCHAIN INVALID"\
      unless num_coins[1] =~ /^\d*$/

      participant_nums = num_coins[0].split('>') # split the participants by their delimiter

      # check to make sure correct number of participants
      if participant_nums.size != 2
        return "Line #{block_num}: Invalid transaction. Must have only 2 participants per transaction."\
        "\nBLOCKCHAIN INVALID"
      end

      # check to make sure both participant accounts are 6 digits
      return "Line #{block_num}: Sender account number is not 6 digits\nBLOCKCHAIN INVALID"\
      unless participant_nums[0] =~ /^\d{6}$/ || participant_nums[0] == 'SYSTEM'

      return "Line #{block_num}: Recipient account number is not 6 digits\nBLOCKCHAIN INVALID"\
      unless participant_nums[1] =~ /^\d{6}$/

      # if sender is not SYSTEM, subtract from their account
      if participant_nums[0] != 'SYSTEM'
        # set account up if doesn't exist
        participants[participant_nums[0]] = 0 unless participants.key?(participant_nums[0])

        participants[participant_nums[0]] -= num_coins[1].to_i
      end

      # check to see if the recipient exists already
      if participants.key?(participant_nums[1])
        participants[participant_nums[1]] += num_coins[1].to_i # add to their existing account
      elsif !participants.key?(participant_nums[1])
        participants[participant_nums[1]] = num_coins[1].to_i # set account up with new value
      end

      # check to make sure the number of coins is a positive integer
      return "Line #{block_num}: Invalid number of coins. Must be a positive integer.\nBLOCKCHAIN INVALID"\
      if num_coins[1].to_i.negative?

      participant_nums.clear # empty the array holding participants for current transaction
    end

    # check to make sure all accounts have non-negative balance after block
    participants.each do |key, value|
      if value.negative?
        return "Line #{block_num}: Invalid block, address #{key} has #{value} billcoins!\nBLOCKCHAIN INVALID"
      end

      participants.delete(key) if value.zero? # remove any participants with 0 balance
    end
    nil
  end

  def verify_time_stamp(segment, previous_time_stamp, block_num)
    # check to make sure timestamp is not empty
    return "Line #{block_num}: Format of timestamp not valid. Cannot be empty\nBLOCKCHAIN INVALID" if segment.empty?

    current_segments = segment.split('.') # split the timestamp into seconds and micros

    # check to make sure there is a number on seconds side of time_stamp
    return "Line #{block_num}: Timestamp cannot be empty on left side of the '.'\nBLOCKCHAIN INVALID"\
    unless current_segments[0] != ''

    # check to make sure there is a number on micros side of time_stamp
    return "Line #{block_num}: Timestamp cannot be empty on right side of the '.'\nBLOCKCHAIN INVALID"\
    unless current_segments.size != 1

    # check to make sure seconds segment is integer
    return "Line #{block_num}: Seconds segment not an integer\nBLOCKCHAIN INVALID"\
    unless current_segments[0] =~ /^\d+$/

    # check to make sure micros is integer
    return "Line #{block_num}: Microseconds segment not an integer\nBLOCKCHAIN INVALID"\
    unless current_segments[1] =~ /^\d+$/

    seconds = current_segments[0].to_i
    micros = current_segments[1].to_i

    prev_segments = previous_time_stamp.split('.') # split the previous time_stamp into seconds and micros
    previous_seconds = prev_segments[0].to_i
    previous_micros = prev_segments[1].to_i

    # when previous seconds is after seconds
    if seconds < previous_seconds
      return "Line #{block_num}: Previous timestamp #{previous_time_stamp} >="\
        " new time_stamp #{segment}\nBLOCKCHAIN INVALID"
    end

    # when seconds match previous seconds but micros < or == previous_micros
    if seconds == previous_seconds
      if micros <= previous_micros
        return "Line #{block_num}: Previous timestamp #{previous_time_stamp} >="\
        " new time_stamp #{segment}\nBLOCKCHAIN INVALID"
      end
    end

    nil
  end

  def verify_block_hash(segment, line, block_num)
    # check to make sure timestamp is not empty
    return "Line #{block_num}: Format of block hash not valid. Cannot be empty\nBLOCKCHAIN INVALID" if segment.empty?

    # check to make sure the hash segment doesn't start with 0
    return "Line #{block_num}: Block hash segment starts with a 0\nBLOCKCHAIN INVALID"\
    unless segment[0] != '0' || segment[1].nil?

    # check to make sure block hash segment is in correct format
    return "Line #{block_num}: Block hash segment not alphanumeric\nBLOCKCHAIN INVALID"\
    unless segment =~ /^[a-zA-Z0-9]+$/

    # check length of block hashs segment
    return "Line #{block_num}: Block hashs segment exceeds 4 characters long\nBLOCKCHAIN INVALID"\
    if segment.size > 4

    calculated_hash = calc_hash(line) # obtain hash value
    if segment != calculated_hash
      return "Line #{block_num}: Hash set to #{segment},"\
      " should be #{calculated_hash}\nBLOCKCHAIN INVALID"
    end

    @block_num += 1 # increment block_num
    nil
  end

  # method that takes a string and returns its hash value
  def calc_hash(line)
    string_hash = 0

    # convert each character to its UTF-8 value
    line.each_char do |x|
      string_hash += @stored_chars[x]
    end

    string_hash = string_hash % 65_536 # mod the string_hash for the final hash value
    string_hash.to_s(16) # convert line hash value to hex
  end

  # method to display account balances
  def print_accounts(participants)
    temp = participants.sort_by { |key| key } # sort the participants by account number ascending
    temp.each do |account|
      puts "#{account[0]}: #{account[1]} billcoins" # print account number and its coins
    end

    nil
  end
end
