require 'sinatra'

get '/' do
	erb :index
end

not_found do
	status 404
	erb :invalid_address_page
end

post '/results' do
	@truth_symbol = params['truth_symbol'].to_s
	@false_symbol = params['false_symbol'].to_s
	@table_size = params['table_size'].to_s

	#if no parameters entered, enter default values
	if @truth_symbol == ""
		@truth_symbol = "T"
	end
	if @false_symbol == ""
		@false_symbol = "F"
	end
	if @table_size == ""
		@table_size = "3"
	end

	is_true = false
	begin
		@table_size = Integer(@table_size)
	rescue
		is_true = true
	end
	
	is_true ||= @truth_symbol.length > 1
	is_true ||= @false_symbol.length > 1
	is_true ||= @truth_symbol == @false_symbol
	is_true ||= @table_size < 2

	if is_true
		erb :error_page
	else
		t_table = build_table
		erb :results, locals: {table_size: @table_size, t_table: t_table}
	end
end

def build_table
	results = []
	t_table = Array.new(2**(@table_size)) { Array.new(@table_size)}
	for r in 0..(2**(@table_size)-1)
		binary_row = r.to_s(2)
		binary_row = binary_row.chars
		while binary_row.length<(@table_size)
			binary_row.unshift("0")
		end
		binary_row = binary_row.map {|x| x == "0" ? false :x}
		binary_row = binary_row.map {|x| x == "1" ? true :x}
		for c in 0..(@table_size-1)
			t_table[r][c] = binary_row[c]
		end
		
		#and or nand nor single xor added to row
		results.push(ander(t_table[r]))
		results.push(orer(t_table[r]))
		results.push(!ander(t_table[r]))
		results.push(!orer(t_table[r]))
		results.push(singler(t_table[r]))
		results.push(xorer(t_table[r]))

		#combine row and results then reset results array
		t_table[r].push(*results)
		results = []

		#convert to symbols
		t_table[r] = t_table[r].map {|x| x == false ? @false_symbol :x}
		t_table[r] = t_table[r].map {|x| x == true ? @truth_symbol :x}

	end
	return t_table
end

def ander(row_array)
	result = true
	for i in 0..(@table_size-1)
		result &= row_array[i]
	end
	return result
end

def orer(row_array)
	result = false
	for i in 0..(@table_size-1)
		result |= row_array[i]
	end
	return result
end

def singler(row_array)
	t_count = row_array.count(true)
	if t_count == 1
		return true
	else 
		return false
	end	
end

def xorer(row_array)
	t_count = row_array.count(true)
	if t_count.odd?
		return true
	else 
		return false
	end
end
