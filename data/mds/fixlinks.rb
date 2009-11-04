file = File.open('links.csv')
file2 = File.open('linksfixed.csv', 'w')

file.each_line do |line|
  file2 << line.split(',').collect{|a| a == '\\N' ? 'Inf' : a}.join(',')
end

file.close
file2.close
