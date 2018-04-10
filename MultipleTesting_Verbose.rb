file_name = ""

while file_name != "idk"
    puts
    puts "***********************************************************************"
    puts "Enter a GenBank file name. If you do not know the name, just type: idk"
    file_name = gets.chomp

end

gb_file_count = %x(ls -l | grep -Eo "U.+.gb" | wc -l).chomp.to_i

puts "*You entered <idk>. I found #{gb_file_count} GenBank files in your directory:"
gb_files = %x(ls -l | grep -Eo "U.+.gb").chomp.to_s

n = 1
while n <= gb_file_count
  gb_files.each do |file|
    puts "#{n}. #{file}"   
    n += 1
  end
end

puts "*Please enter the corresponding two numbers for the files you want me to analyze, separated by commas:"
option = gets.chomp.to_s


file_array=Array.new

option.split(/,/).each do |each_choice|
  file_array.push(each_choice)
end

file_1 = %x(ls -l | grep -m #{file_array[0]} -Eo "U.{5}.gb" | tail -n 1).chomp.to_s
file_2 = %x(ls -l | grep -m #{file_array[1]} -Eo "U.{5}.gb" | tail -n 1).chomp.to_s

puts "You chose the following files: #{file_1} and #{file_2}. Do you want to proceed (y/n)?"
proceed = gets.chomp.to_s


until proceed == "y"
  if proceed == "n"
     puts "*You chose to not proceed!"
     puts "*Please enter the corresponding numbers for the files you want me to analyze:"
     option = gets.chomp.to_s
     file_array = Array.new
     option.split(/,/).each do |each_choice|
      file_array.push(each_choice)
     end
     file_1 = %x(ls -l | grep -m #{file_array[0]} -Eo "U.{5}.gb" | tail -n 1).chomp.to_s
     file_2 = %x(ls -l | grep -m #{file_array[1]} -Eo "U.{5}.gb" | tail -n 1).chomp.to_s
     puts "*You chose files #{file_1} and #{file_2}."
     puts "*Do you wish to proceed with the analysis now? (y/n)"
     proceed = gets.chomp
  elsif proceed != "y" && proceed != "n"
     puts "*I cannot recognize what that is. Please enter \"y\" or \"n\" for \"yes\" or \"no\": "
     proceed = gets.chomp.to_s
  else
  end
end



puts
puts "*Okay - here is what I found....."
puts

gene_hash_1 = Hash.new

ref_line_1 = %x(grep -m 1 "JOURNAL" #{file_1} | awk -F "   " '{print $2}').chomp.to_s

org_name_1 = %x(grep -m 1 "/organism" #{file_1} | awk -F "=" '{print $2}').chomp.to_s

gene_count_1 = %x(grep "/gene" #{file_1} | sort | uniq | wc -l ).chomp.to_i

#gene_start_1 = %x(grep -m 1 -w "gene" #{file_1} | awk '{print $2}' | awk -F "." '{print $1}').chomp.to_i

#gene_end_1 = %x(grep -m 1 -w "gene" #{file_1} | awk '{print $2}' | awk -F "." '{print $3}').chomp.to_i


gene_hash_2 = Hash.new

ref_line_2 = %x( grep -m 1 "JOURNAL" #{file_2} | awk -F "   " '{print $2}').chomp.to_s

org_name_2 = %x(grep -m 1 "/organism" #{file_2} | awk -F "=" '{print $2}').chomp.to_s

gene_count_2 = %x(grep "/gene" #{file_2} | sort | uniq | wc -l ).chomp.to_i

#gene_start_2 = %x(grep -m 1 -w "gene" #{file_2} | awk '{print $2}' | awk -F "." '{print $1}').chomp.to_i

#gene_end_2 = %x(grep -m 1 -w "gene" #{file_2} | awk '{print $2}' | awk -F "." '{print $3}').chomp.to_i



i = 1
while i <= gene_count_1
  gene_string = %x(grep -w "/gene" #{file_1} | uniq | grep -m #{i} "\/gene" | tail -n 1 | awk -F "=" '{print $2}' | awk -F '"' '{print $2}').chomp.to_s
  gene_start = %x(grep -m #{1+3*(i-1)} -w "gene" #{file_1} | tail -n 1 | awk '{print $2}' | grep -Eo "/*[(]*([0-9])\.\.[0-9]/").chomp.to_i
  gene_end = %x(grep -m #{1+3*(i-1)} -w "gene" #{file_1} | tail -n 1 | awk '{print $2}' | awk -F "." '{print $3}').chomp.to_i
# gene_start = %x(grep -m #{1+3*(i-1)} -w "gene" #{file_1} | tail -n 1 | awk '{print $2}' | awk -F "." '{print $1}').chomp.to_i
# gene_end = %x(grep -m #{1+3*(i-1)} -w "gene" #{file_1} | tail -n 1 | awk '{print $2}' | awk -F "." '{print $3}').chomp.to_i
  gene_length = gene_end.to_i - gene_start
  gene_hash_1[gene_string] = gene_length.to_i
  i += 1
end

j = 1
while j <= gene_count_2
  gene_string = %x(grep -w "/gene" #{file_2} | uniq | grep -m #{j} "\/gene" | tail -n 1 | awk -F "=" '{print $2}' | awk -F '"' '{print $2}').chomp.to_s
  gene_start = %x(grep -m #{1+3*(j-1)} -w "gene" #{file_2} | tail -n 1 | awk '{print $2}' | awk -F "." '{print $1}').chomp.to_i
  gene_end = %x(grep -m #{1+3*(j-1)} -w "gene" #{file_2} | tail -n 1 | awk '{print $2}' | awk -F "." '{print $3}').chomp.to_i
  gene_length = gene_end - gene_start
  gene_hash_2[gene_string] = gene_length.to_i
  j += 1
end


####TODO: PRINT MIN AND MAX CORRECTLY

puts
puts "******************Summary for file #{file_1}************************"
puts "1. The latest publication is: #{ref_line_1} "
puts "2. The organism source is: #{org_name_1}"
puts "3. The total number of genes is: #{gene_count_1}"
puts "4. The longest gene is #{gene_hash_1.max_by{|k,v| v}} and the shortest is #{gene_hash_1.min_by{|k,v| v}}"
gene_hash_1.sort.each do |key, value|
  puts " The gene #{key} has a length of #{value}"
end
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


####TODO: PRINT MIN AND MAX CORRECTLY

puts
puts "******************Summary for file #{file_2}************************"
puts "1. The latest publication is: #{ref_line_2} "
puts "2. The organism source is: #{org_name_2}"
puts "3. The total number of genes is: #{gene_count_2}" 
puts "4. The longest gene is #{gene_hash_2.max_by{|k,v| v}} and the shortest is #{gene_hash_2.min_by{|k,v| v}}"
gene_hash_2.sort.each do |key, value|
  puts " The gene #{key} has a length of #{value}"
end
puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
puts


query = ""
while query != "stop"
  puts
  puts "*Please enter a gene name you would like me to query (e.g. COI). I will only exit when you enter \"stop\":"
  query = gets.chomp.to_s
  if query != "stop"
    puts "*The length of gene #{query} in file <#{file_1}> is #{gene_hash_1[query]} and in file <#{file_2}> is #{gene_hash_2[query]}"
        if gene_hash_1[query].to_i < gene_hash_2[query].to_i
          puts "the gene #{query} is shorter in #{org_name_1} than in #{org_name_2}"
        elsif gene_hash_1[query].to_i > gene_hash_2[query].to_i
          puts "the gene #{query} is longer in #{org_name_1} than in #{org_name_2}"
        else
          puts "the gene #{query} is the same length in both #{org_name_1} and #{org_name_2}"
        end
  else
  end
end
