require 'Nokogiri'
require 'csv'
require_relative 'Prisoner.rb'

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

def wrapPrisonerTypeSections( list )
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

def getPrisonerTypeSections( list )
    list = list.to_s
    list = wrapPrisonerTypeSections( list )
    list = Nokogiri::HTML( list )
    list.encoding = 'utf-8'


    prisonerTypeSections = []
    ('A'..'G').each do |letter|
        prisonerTypeSections.push( list.css( '#' + letter + '-prisoner-type' ).to_s );
    end
    return prisonerTypeSections
end

def wrapPrisonerSections( prisonerTypeSection )
    firstPrisonerAlreadyFound = false

    (1..98).each do |prisNum|
        regex = prisonerTypeSection.scan( /<b>\s*#{prisNum}\./ )

        if !regex.empty?
            if (!firstPrisonerAlreadyFound)
                prisonerTypeSection = prisonerTypeSection.gsub( /<b>\s*#{prisNum}\./, '<div id="prisoner-' + prisNum.to_s + '"> \\0')
                firstPrisonerAlreadyFound = true
            else
                prisonerTypeSection = prisonerTypeSection.gsub( /<b>\s*#{prisNum}\./, '</div><div id="prisoner-' + prisNum.to_s + '"> \\0')
            end
        end
    end

    prisonerTypeSection = prisonerTypeSection + '</div>'

    return prisonerTypeSection
end

def getPrisonerSections( prisonerTypeSections )
    prisonerSections = []

    prisonerTypeSections.each do |prisonerTypeSection|
        prisonerSectionsOfThisType = []
        prisonerTypeSection = wrapPrisonerSections( prisonerTypeSection )
        prisonerTypeSection = Nokogiri::HTML( prisonerTypeSection )
        prisonerTypeSection.encoding = 'utf-8'

        (1..98).each do |j|
            prisonerSectionText = prisonerTypeSection.css('#prisoner-' + j.to_s).to_s
            if prisonerSectionText.length != 0
                prisonerSection = Prisoner.new( j, prisonerSectionText )

                prisonerSectionsOfThisType.push( prisonerSection )
            end
        end
        prisonerSections.push( prisonerSectionsOfThisType )
    end

    return prisonerSections
end

def cleanValue( value )
    value = value.to_s

    ## Remove all tags
    value = value.gsub(/<(.|\n)*?>/, '')
    value = value.strip()

    return value
end

def cleanCharges ( charges )
    charges = charges.to_s

    ## Remove all tags
    charges = charges.gsub(/<(.|\n)*?>/, '')
    charges = charges.strip()

    return charges
end

def cleanDate( date )
    date = date.to_s

    ## Remove incomplete tag and page number in prisoner ID 36
    date = date.gsub(/<a(.*)47/m, '')

    date = cleanValue(date)

    return date
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

def pushDateAndDateType( row, prisonerSection)
    prisonerText = prisonerSection.getWholeTextAsNokogiri

    dateOfArrest = prisonerText.css('.date-of-arrest')
    dateOfDetention = prisonerText.css('.date-of-detention')
    dateOfPretrialDetention = prisonerText.css('.date-of-pretrial-detention')

    if !dateOfArrest.empty?
        row.push( cleanDate(dateOfArrest))
        prisonerSection.setDateType=('Arrest')
        row.push prisonerSection.getDateType
        return row
    elsif !dateOfDetention.empty?
        row.push( cleanDate(dateOfDetention))
        prisonerSection.setDateType=('Detention')
        row.push prisonerSection.getDateType
        return row
    elsif !dateOfPretrialDetention.empty?
        row.push( cleanDate(dateOfPretrialDetention))
        prisonerSection.setDateType=('Pretrial Detention')
        row.push prisonerSection.getDateType
        return row
    end

    return row

end

def getRowFromPrisonerSection( prisonerSection, prisTypeNum )
    row = []

    prisonerText = prisonerSection.getWholeText

    if prisonerSection.getId == 1
        puts prisonerSection
    end

    prisonerText = Nokogiri::HTML( prisonerText )
    prisonerText.encoding = 'utf-8'

    row.push(prisonerSection.getId())

    row.push(prisonerSection.getName)
    row.push( getPrisonerType( prisTypeNum ))
    row = pushDateAndDateType( row, prisonerSection )
    row.push( cleanCharges( prisonerText.css('.charges')))

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
    prisonerTypeSections = getPrisonerTypeSections( list )
    prisonerSections = getPrisonerSections( prisonerTypeSections )
    rows = getRowsFromPrisonerSections( prisonerSections )

    writeRowsToOutput( rows, output_path )
end

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'

outputDataFromHtmlList( input_path, output_path )


