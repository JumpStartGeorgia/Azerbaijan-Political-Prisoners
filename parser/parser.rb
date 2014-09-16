require 'Nokogiri'
require 'csv'

def getCsvFromList( list_path, csv_path )

  list = Nokogiri::HTML( open( list_path ))
  #list.xpath('//br').remove()

## Data gathered from list_input: Prisoner name, Date of Arrest, Charges (array), Place of Detention, Background Description, Picture
  rows = []
  (1..98).each do |i|

    name = list.xpath('//b[starts-with(., "' + i.to_s + '.")]')

    row = []
    row.push(name)
    rows.push(row)
  end

## WRITE TO FILE
  CSV.open( csv_path, 'wb' ) do |csv|
    #Each row should have the first name of the person, followed by the last name
    csv << [ 'Name', 'Type of Person', 'Date of Arrest', 'Charges', 'Place of Detention', 'Background Description', 'Picture' ]

    rows.each do |row|
      csv << row
    end

  end
end

getCsvFromList( File.dirname(__FILE__) + '/../list.html', File.dirname(__FILE__) + '/../output.csv' )
getCsvFromList( File.dirname(__FILE__) + '/../cleanList.html', File.dirname(__FILE__) + '/../cleanOutput.csv' )

