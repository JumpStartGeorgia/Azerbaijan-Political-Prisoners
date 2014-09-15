require 'rubygems'
require 'Nokogiri'
require 'csv'

list = Nokogiri::HTML(open( File.dirname(__FILE__) + '/../list.html' ))

rows = []
rows.push([ 'Nathan', 'Shane' ])
rows.push([ 'James', 'Dean' ])
rows.push([ 'Joe', 'Hobbit' ])
rows.push([ 'John', 'Hobbit' ])

CSV_FILE_PATH = File.join( File.dirname(__FILE__), '../output.csv' );

CSV.open( CSV_FILE_PATH, 'wb' ) do |csv|
  #Each row should have the first name of the person, followed by the last name
  csv << ['first', 'last']
  rows.each {
    |row|
    csv << row
  }

end
