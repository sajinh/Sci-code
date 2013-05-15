require 'pp'
require './iri_data_parser'

infil="ensofcst_ALLto0313rename"
parser=IRIDParser.new(infil)
sup_arr=parser.parse

model_data_arr = []
sup_arr.each do |arr|
  model_data_arr << arr[:models]
end
model_data=model_data_arr.flatten


models =  model_data.flatten.uniq

# Find the frequency of occurence of each model
freq = models.map { |model| model_data.count(model)}

mfreq = Hash[*models.zip(freq).flatten]
sorted_mfreq = mfreq.sort_by {|k,v| v}
sorted_models = []

# Print the frequency against model
i=1
sorted_mfreq.each do |k,v|
  print "#{i})\t#{k}\s#{v}\n"
   sorted_models << k
  i+=1
end

# Find the time span of each model
mspan= sorted_models.map {[]}
model_data_arr.each_with_index do |marr,i|

  sorted_models.each_with_index {|m,idx| (mspan[idx] << i) if marr.include?(m) }
end

# Find if we have models that have discontinuous records

spc="\s"
mspan.each_with_index do |model,im|
  
  diff=  (model[-1]-model[0]+1) - model.length
  if diff != 0
     puts "Model #{sorted_models[im]} data missing for #{diff} seasons"
  end
end
