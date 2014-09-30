require 'Nokogiri'
require 'csv'
require_relative 'List.rb'
require_relative 'Prisoner.rb'
require_relative 'PrisonerType.rb'

def getPrisonerTypes( list )
    list = Nokogiri::HTML( list )
    list.encoding = 'utf-8'

    prisonerTypes = []
    ('A'..'G').each do |letter|
        prisonerType = PrisonerType.new( list.css( '#' + letter + '-prisoner-type' ).to_s, letter )
        prisonerTypes.push( prisonerType )
    end
    return prisonerTypes
end

def getPrisoners( prisonerTypes )
    prisoners = []

    prisonerTypes.each do |prisonerType|
        prisoners.concat(prisonerType.getPrisoners)
    end

    return prisoners
end

def writePrisonerValuesToOutput( prisoners, output_path )
    CSV.open( output_path, 'wb') do |csv|
        csv << ['ID', 'Name', 'Type of Prisoner', 'Date', 'Type of Date','Charges', 'Place of Detention', 'Background Description', 'Picture']

        prisoners.each do |prisoner|
            csv << [prisoner.getId, prisoner.getName, prisoner.getPrisonerType.getName, prisoner.getDate, prisoner.getDateType, prisoner.getCharges]
        end
    end
end

def outputDataFromHtmlList(input_path, output_path)
    list = List.new(input_path)
    prisonerTypes = getPrisonerTypes( list.getContents )
    prisoners = getPrisoners( prisonerTypes )
    writePrisonerValuesToOutput( prisoners, output_path )
end

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'

outputDataFromHtmlList( input_path, output_path )


