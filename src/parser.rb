require 'Nokogiri'
require 'csv'
require_relative 'Prisoner.rb'
require_relative 'PrisonerType.rb'

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
    list.xpath('//br').remove()
    list.xpath('//hr').remove()

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
    file = File.open(input_path, "rb")
    list = file.read
    file.close

    list = removePageRelatedTags( list )

    list = Nokogiri::HTML( list )
    list.encoding = 'utf-8'
    list = removeUnnecessaryTags( list )

    list = list.to_s
    list = wrapPrisonerTypes( list )
    list = Nokogiri::HTML( list )
    list.encoding = 'utf-8'

    return list
end

def getPrisonerTypes( list )
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
        prisonerTypeText = prisonerType.getWholeTextAsNokogiri

        (1..98).each do |j|
            prisonerText = prisonerTypeText.css('#prisoner-' + j.to_s).to_s
            if prisonerText.length != 0
                prisoner = Prisoner.new( j, prisonerType, prisonerText )
                prisoners.push( prisoner )
            end
        end
    end

    return prisoners
end

def getRowFromPrisoner( prisoner )
    row = []
    row.push(prisoner.getId)
    row.push(prisoner.getName)
    row.push(prisoner.getPrisonerType.getName)
    row.push(prisoner.getDate)
    row.push(prisoner.getDateType)
    row.push(prisoner.getCharges)

    return row
end

def getRowsfromPrisoners( prisoners )
    rows = []

    prisoners.each do |prisoner|
        rows.push( getRowFromPrisoner( prisoner ))
    end

    return rows
end

def writeRowsToOutput( rows, output_path )
    CSV.open( output_path, 'wb') do |csv|
        csv << ['ID', 'Name', 'Type of Prisoner', 'Date', 'Type of Date','Charges', 'Place of Detention', 'Background Description', 'Picture']

        rows.each do |row|
            csv << row
        end
    end
end

def outputDataFromHtmlList(input_path, output_path)
    list = prepareList( input_path )
    prisonerTypes = getPrisonerTypes( list )
    prisoners = getPrisoners( prisonerTypes )
    rows = getRowsfromPrisoners( prisoners )
    writeRowsToOutput( rows, output_path )
end

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'

outputDataFromHtmlList( input_path, output_path )


