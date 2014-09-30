require 'Nokogiri'
require 'csv'
require_relative 'List.rb'

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'

#Create list object containing cleaned and structured HTML
list = List.new(input_path, output_path)

list.findPrisonerTypes

list.getPrisonerTypes.each do |prisonerType|
    prisonerType.findPrisoners
end

list.writePrisonerValuesToOutput


