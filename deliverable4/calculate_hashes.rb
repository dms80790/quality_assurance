stored_chars = {}

(0..9).each do |n|
  n = n.to_s
  m = n.unpack('U')
  x = m[0]
  char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
  stored_chars[n] = char_hash
end

('a'..'z').each do |n|
  m = n.unpack('U')
  x = m[0]
  char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
  stored_chars[n] = char_hash
end

('A'..'Z').each do |n|
  m = n.unpack('U')
  x = m[0]
  char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
  stored_chars[n] = char_hash
end

m = '|'.unpack('U')
x = m[0]
char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
stored_chars['|'] = char_hash

m = '.'.unpack('U')
x = m[0]
char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
stored_chars['.'] = char_hash

m = ':'.unpack('U')
x = m[0]
char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
stored_chars[':'] = char_hash

m = '('.unpack('U')
x = m[0]
char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
stored_chars['('] = char_hash

m = ')'.unpack('U')
x = m[0]
char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
stored_chars[')'] = char_hash

m = '>'.unpack('U')
x = m[0]
char_hash = ((x**3000) + (x**x) - (3**x)) * (7**x)
stored_chars['>'] = char_hash

# Open output file write-only access
File.open('stored_char_hashes.txt', 'w') do |file|
  # For each line in the array, write it to the file
  stored_chars.each do |key, value|
    file.write(key)
    file.write(', ')
    file.write(value)
    file.write('\n')
  end
end
