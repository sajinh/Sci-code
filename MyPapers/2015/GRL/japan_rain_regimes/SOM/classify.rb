# discretize weights into 3 classes
# check dominancy in each class
#   defined by at least 1 level of superiority of the class in question
#   above other classes.

som_map="rain.fin_map"
data = []
IO.readlines(som_map)[1..-1].each do |line|
  line.chomp!
  data << line.split.map {|col| (1+(col.to_f/0.3).floor).to_i}
end


nvec,topol,xdim,ydim = IO.readlines(som_map)[0].chomp.split[0..3]
puts "Inter Decadal nodes"
idc=[]
# check for dominant inter decadal nodes
k=0
(1..ydim.to_i).each do |j|
  (1..xdim.to_i).each do |i|
    node=data[k] 
    if ((node[0]>node[1]) and (node[0]>node[2]))
       idc << "#{i-1}_#{j-1}"
       p node.join(",")
    end
    k+=1
  end 
end

puts "Decadal nodes"
dec=[]
# check for dominant decadal nodes
k=0
(1..ydim.to_i).each do |j|
  (1..xdim.to_i).each do |i|
    node=data[k] 
    if ((node[1] > node[0]) and (node[1] > node[2]))
       dec << "#{i-1}_#{j-1}"
       p node.join(",")
    end
    k+=1
  end 
end

puts "interannual nodes"
int=[]
# check for dominant interannual nodes
k=0
(1..ydim.to_i).each do |j|
  (1..xdim.to_i).each do |i|
    node=data[k] 
    #puts node.join(" ")
    if ((node[2] > node[1]) and (node[2] > node[0]))
       int << "#{i-1}_#{j-1}"
       p node.join(",")
    end
    k+=1
  end 
end

File.open("typ1_nodes.txt","w") {|f| f.puts idc}
File.open("typ2_nodes.txt","w") {|f| f.puts dec}
File.open("typ3_nodes.txt","w") {|f| f.puts int}
