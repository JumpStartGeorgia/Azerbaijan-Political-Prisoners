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

def prepareList( input_path )
    file = File.open(input_path, "rb")
    list = file.read
    file.close

    list = removePageRelatedTags( list )

    list = Nokogiri::HTML( list )
    list.encoding = 'utf-8'
    list = removeUnnecessaryTags( list )

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

def getPrisonerTypes( list )
    list = list.to_s
    list = wrapPrisonerTypes( list )
    list = Nokogiri::HTML( list )
    list.encoding = 'utf-8'

    prisonerTypes = []
    ('A'..'G').each do |letter|
        prisonerType = PrisonerType.new( list.css( '#' + letter + '-prisoner-type' ).to_s )
        prisonerTypes.push( prisonerType );
    end
    return prisonerTypes
end



def getPrisoners( prisonerTypes )
    prisonerSections = []

    prisonerTypes.each do |prisonerType|
        prisonerSectionsOfThisType = []
        prisonerTypeText = prisonerType.getWholeTextAsNokogiri

        (1..98).each do |j|
            prisonerSectionText = prisonerTypeText.css('#prisoner-' + j.to_s).to_s
            if prisonerSectionText.length != 0
                prisonerSection = Prisoner.new( j, prisonerSectionText )

                prisonerSectionsOfThisType.push( prisonerSection )
            end
        end
        prisonerSections.push( prisonerSectionsOfThisType )
    end

    return prisonerSections
end

def getPrisonerType( prisTypeNum )
    if prisTypeNum == 1
        return 'Journalists and Bloggers'
    elsif prisTypeNum == 2
        return 'Human Rights Defenders'
    elsif prisTypeNum == 3
        return 'Youth Activists'
    elsif prisTypeNum == 4
        return 'Politicians'
    elsif prisTypeNum == 5
        return 'Religious Activists'
    elsif prisTypeNum == 6
        return 'Lifetime Prisoners'
    elsif prisTypeNum == 7
        return'Other Cases'
    end
end

def getRowFromPrisonerSection( prisonerSection, prisTypeNum )
    row = []
    row.push(prisonerSection.getId)
    row.push(prisonerSection.getName)
    row.push( getPrisonerType( prisTypeNum ))
    row.push(prisonerSection.getDate)
    row.push(prisonerSection.getDateType)
    row.push(prisonerSection.getCharges)

    return row
end

def getRowsFromPrisonerSections( prisonerSectionsByType )
    rows = []
    prisTypeNum = 1

    prisonerSectionsByType.each do |prisonerSectionsOneType|
        prisonerSectionsOneType.each do |prisonerSection|
            rows.push( getRowFromPrisonerSection( prisonerSection, prisTypeNum ))
        end
        prisTypeNum+=1
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
    prisonerTypeSections = getPrisonerTypes( list )
    prisonerSections = getPrisoners( prisonerTypeSections )
    rows = getRowsFromPrisonerSections( prisonerSections )

    writeRowsToOutput( rows, output_path )
end

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'

outputDataFromHtmlList( input_path, output_path )


