require 'sinatra'
require 'sinatra/reloader'
def generate_table(size, truth_symbol, false_symbol)
    
	truth_table = []
	
	ary = 0
	(2**size).times do
	  truth_table[ary] = []
	  ary += 1
	end
	
	row = 0
	(2**size).times do
	  shift_amt = 0
	  row_sum = 0
	  
	  size.times do
	    if((row >> shift_amt) & 1 == 1)
		  truth_table[row][(size-1)- shift_amt] = truth_symbol
		  row_sum += 1
		else
		  truth_table[row][(size-1) - shift_amt] = false_symbol
		end		
        
		shift_amt += 1
	  end
	  
	  if (row_sum == size)
	    truth_table[row][size] = truth_symbol
      else
	    truth_table[row][size] = false_symbol
	  end
	  
	  if (row_sum >= 1)
	    truth_table[row][size + 1] = truth_symbol
	  else
	    truth_table[row][size + 1] = false_symbol
	  end
	  
	  if (row_sum != size)
	    truth_table[row][size + 2] = truth_symbol
      else
	    truth_table[row][size + 2] = false_symbol
	  end
	  
	  if (row_sum == 0)
	    truth_table[row][size + 3] = truth_symbol
	  else
	    truth_table[row][size + 3] = false_symbol
	  end
	 
	  row += 1
	end
	
	return truth_table
end

not_found do
  status 404
  erb :error
end

get '/' do
  ps = params['size']
  truth_symbol = params['truth_symbol']
  false_symbol = params['false_symbol']
  size = ps.to_i
  
  unless(truth_symbol.nil? && false_symbol.nil? && ps.nil?)
    if (truth_symbol == '')
      truth_symbol = 'T'
      end
    if (false_symbol == '')
      false_symbol = 'F'
      end
    if (ps == '')
      size = 3
    end
  
    #if invalid size was entered
    if !(size >=2)
      error = true
    #if invalid false_symbol or truth_symbol entered
    elsif false_symbol == truth_symbol || false_symbol.length > 1 || truth_symbol.length > 1
      error = true
    # if all values are valid
    else
      valid = true
	  
	  truth_table = generate_table(size, truth_symbol, false_symbol)
    end
  end
  #end
  erb :main, :locals => { size: size, truth_symbol: truth_symbol, false_symbol: false_symbol, truth_table: truth_table, valid: valid, error: error}
end
