
# f(x) = 2f(x - 1) + 1 if  : f(1) = 1 : f(2) = 2
# for use with solving the time complexity for the bug I mention in my readme.

X = 2000
x_array = [1, 2]

(X - 2).times do |i|

    x_array.push(2 * x_array[i + 1] + 1)

end

result = ""
x_array.each_with_index {|val, i| result += "f(#{i + 1}) = #{val}\n"}

File.open("bug_lookup_table.txt", "w") { |f| f.write result}