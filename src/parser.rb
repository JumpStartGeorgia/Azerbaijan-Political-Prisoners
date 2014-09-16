require 'Nokogiri'
require 'csv'

def getName( list, i )
  name = list.xpath(
      '//b[starts-with(normalize-space(.), "' + i.to_s + '.")
        and not(contains(normalize-space(.), "' + (i + 1).to_s + '."))
        and not(contains(normalize-space(.), "Public Union"))]'
  ).text

  stringsToRemove = [ i.to_s + '.', ':', 'Date of arrest', 'Date of Detention', 'Date of detention', 'Detention date']

  stringsToRemove.each do |string|
    name.gsub! string, ''
  end

  return name.lstrip.rstrip
end

def getCsvFromHtml( html_path, csv_path )

  #Prepare list
  list = Nokogiri::HTML( open( html_path ))
  list.xpath('//br').remove()
  rows = []

  (1..98).each do |i|
    name = getName( list, i )

    rows.push( [name] )
  end

  #Write to file
  CSV.open( csv_path, 'wb' ) do |csv|
    #Each row should have the first name of the person, followed by the last name
    csv << [ 'Name', 'Type of Person', 'Date of Arrest', 'Charges', 'Place of Detention', 'Background Description', 'Picture' ]

    rows.each do |row|
      csv << row
    end

  end
end

getCsvFromHtml( File.dirname(__FILE__) + '/../input/list.html', File.dirname(__FILE__) + '/../output/output.csv' )
getCsvFromHtml( File.dirname(__FILE__) + '/../input/cleanList.html', File.dirname(__FILE__) + '/../output/cleanOutput.csv' )

