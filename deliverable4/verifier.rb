require 'flamegraph'
require_relative 'verifier_checker.rb'
Flamegraph.generate('flamegrapher.html') do
  if ARGV.count != 1 || !File.file?(ARGV[0])
    puts "Usage: ruby verifier.rb <name_of_file>\n       name_of_file = name of file to verify"
    exit
  end
  input_file = ARGV[0] # Otherwise, assign the file to input_file
  lines = [] # create an empty array, lines
  File.open(input_file, 'r').each_line do |line| # Open file input_file in read-only mode
    lines << line.chomp
  end
  hashes = Hash[*File.read('stored_char_hashes.txt').split(/[, \n]+/)] # Open stored_char_hashes.txt in read-only mode
  hashes.each do |key, value|
    hashes[key] = value.to_i
  end
  billcoin_verifier = VerifierChecker.new(lines, hashes) # create a new verifier instance
  return_value = billcoin_verifier.start
  puts return_value unless return_value.nil?
end
