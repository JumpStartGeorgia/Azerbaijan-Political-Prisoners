require 'Nokogiri'
require 'csv'
require_relative 'List.rb'

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'
list = List.new(input_path, output_path)
list.writePrisonerValuesToOutput


