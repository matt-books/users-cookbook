#!/usr/bin/ruby -w 

# This script takes a ruby hash structure as configuration and
# creates the Chef-cookbook config file attributes/default.rb

####################################
# Syntax check
##############################

if !(ARGV[0]) then
	STDERR.puts "incorrect syntax:\t#{$0} #{ARGV[0]}"
	abort "correct syntax:\t\t#{$0} <your_config.template>"
end

load ARGV[0]

@custom_json = custom_json
@attributes = Array.new

@custom_json.each do |key1, value1|

	# if value is one of these types, than push it and we are done
	# with this branch of the hash

	if value1.kind_of?(String) || 
		value1.kind_of?(TrueClass) || 
		value1.kind_of?(FalseClass) ||
		value1.kind_of?(Fixnum) ||
		value1.kind_of?(Float)
		then

		# if it's a string we need to put ' quotes ' around it
		if value1.kind_of?(String) then
			@attributes.push("default[\'#{key1}\'] = \'#{value1}\'")
		else
			@attributes.push("default[\'#{key1}\'] = #{value1}")
		end
		next
	end

	# if key1, value1 is an object (something other than the .kind_of? classes above),
	# then iterate over value1 object
	value1.each do |key2, value2|
		# if value is one of these types, than push it and we are done
		# with this branch of the hash
		if value2.kind_of?(String) || 
			value2.kind_of?(TrueClass) || 
			value2.kind_of?(FalseClass) ||
			value2.kind_of?(Fixnum) ||
			value2.kind_of?(Float)
			then

			if value2.kind_of?(String) then
				@attributes.push("default[\'#{key1}\'][\'#{key2}\'] = \'#{value2}\'")
			else
				@attributes.push("default[\'#{key1}\'][\'#{key2}\'] = #{value2}")
			end
			next
		end

		value2.each do |key3, value3|
			# then dive into the 3rd level of keys.. this code should probably be implemented
			# as a recursive algorithm, allowing a N-deep hash
			if value3.kind_of?(String) || 
				value3.kind_of?(TrueClass) || 
				value3.kind_of?(FalseClass) ||
				value3.kind_of?(Fixnum) ||
				value3.kind_of?(Float) ||
				value3.kind_of?(Array)
				then

				if value3.kind_of?(String) then
					@attributes.push("default[\'#{key1}\'][\'#{key2}\'][\'#{key3}\'] = \'#{value3}\'")
				else
					#@attributes.push("default[\'#{key1}\'][\'#{key2}\'][\'#{key3}\'] = #{value3}")
				end
				if value3.kind_of?(Array) then
					i = 0
					value3.each do |value4|
						if value4.kind_of?(String) then
							@attributes.push("default[\'#{key1}\'][\'#{key2}\'][\'#{key3}\'][#{i}] = \'#{value4}\'")
						else
							@attributes.push("default[\'#{key1}\'][\'#{key2}\'][\'#{key3}\'][#{i}] = #{value4}")
						end
						i += 1
					end
				end
				next
			end
		end
	end
end

outfile = File.open("attributes/default.rb", "w")
outfile.puts "\
# This file should not be edited manually!! \n\
# \n\
# Instead, modify #{ARGV[0]}\n\
# Recreate me with #{$0} #{ARGV[0]}\n\
# Converge\n\
###\n"


puts @attributes
puts "\n\n\n\t* Writing default.rb...\n\n"
outfile.puts @attributes
