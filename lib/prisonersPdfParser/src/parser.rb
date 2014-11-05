require 'Nokogiri'
require 'csv'
require_relative 'List.rb'

#Create list object containing cleaned and structured HTML
input_path = File.dirname(__FILE__) + '/../input/list.html'
list = List.new(input_path)

#Find the prisoner type sections in the list
list.findPrisonerTypes

#Find the prisoners in each of those sections
list.getPrisonerTypes.each do |prisonerType|
    prisonerType.findPrisoners
end

#Output values to CSV
prisonersOutputPath = File.dirname(__FILE__) + '/../output/prisoners.csv'
subtypesOutputPath = File.dirname(__FILE__) + '/../output/subtypes.csv'
placesOfDetentionOutputPath = File.dirname(__FILE__) + '/../output/placesOfDetention.csv'
articlesOutputPath = File.dirname(__FILE__) + '/../output/articles.csv'
list.outputPrisoners(prisonersOutputPath)
list.outputSubtypes(subtypesOutputPath)
list.outputPlacesOfDetention(placesOfDetentionOutputPath)
list.outputArticles(articlesOutputPath)