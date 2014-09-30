require 'Nokogiri'
require 'csv'
require_relative 'Prisoner.rb'
require_relative 'PrisonerType.rb'

def openList( input_path )
    file = File.open(input_path, "rb")
    list = file.read
    file.close

    return list;
end

def removePageRelatedTags( list )
    (1..92).each do |i|
        pageRegex = '<a name=' + i.to_s + '><\/a>(?:' + i.to_s + ')?'

        list = list.gsub!(/#{pageRegex}/, '')

        if (!list)
            raise 'Did not find tags related to page #' + i.to_s + ' to remove from list. Regex search: ' + pageRegex
        end
    end

    return list
end

def removeUnnecessaryTags( list )
    list = Nokogiri::HTML( list )
    list.encoding = 'utf-8'

    list.xpath('//br').remove()
    list.xpath('//hr').remove()

    list = list.to_s
    return list
end

def wrapPrisonerTypes( list )
    ('A'..'G').each do |letter|
        if letter == 'A'
            list = list.gsub( /<b>#{letter}\./, '<div id="' + letter + '-prisoner-type"> \\0' )
        elsif letter == 'G'
            list = list.gsub( /<b>#{letter}\./, '</div><div id="' + letter + '-prisoner-type"> \\0' )
            list = list.gsub( /<\/body>/, '</div></body>')
        else
            list = list.gsub( /<b>#{letter}\./, '</div><div id="' + letter + '-prisoner-type"> \\0' )
        end
    end

    return list
end

def prepareList( input_path )
    list = openList(input_path)
    list = removePageRelatedTags( list )
    list = removeUnnecessaryTags( list )
    list = wrapPrisonerTypes( list )

    return list
end

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
    list = prepareList( input_path )
    prisonerTypes = getPrisonerTypes( list )
    prisoners = getPrisoners( prisonerTypes )
    writePrisonerValuesToOutput( prisoners, output_path )
end

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'

outputDataFromHtmlList( input_path, output_path )


