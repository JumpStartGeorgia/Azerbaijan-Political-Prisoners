require 'Nokogiri'
require 'csv'

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
            prisonerSection = prisonerTypeSection.css('#prisoner-' + j.to_s).to_s
            if prisonerSection.length != 0
                prisonerSectionsOfThisType.push( prisonerSection )
            end
        end
        prisonerSections.push( prisonerSectionsOfThisType )
    end

    return prisonerSections
end

def wrapDataValues( prisNum, prisonerSection )
    prisonerSection = prisonerSection.gsub(
        /<b>\s*#{prisNum}\./,
        '<span class="prisoner-name">\\0'
    )

    arrestRegexPatterns = ['Date of arrest:', 'Date of arrest\s*<\/b>:']

    arrestRegexPatterns.each do |pattern|
        prisonerSection = prisonerSection.gsub(
            /#{pattern}/,
            '</span>\\0<span class="date-of-arrest">'
        )
    end

    detentionRegexPatterns = ['Detention date:', 'Date of Detention:', 'Date of detention:', 'Date of Detention</b>:']

    if !prisonerSection.scan('detention decision was made on').empty?
        detentionRegexPatterns.each do |pattern|
            prisonerSection = prisonerSection.gsub(
                /#{pattern}/,
                '</span>\\0<span class="date-of-pretrial-detention">'
            )
        end
    else
        detentionRegexPatterns.each do |pattern|
            prisonerSection = prisonerSection.gsub(
                /#{pattern}/,
                '</span>\\0<span class="date-of-detention">'
            )
        end
    end

    prisonerSection = prisonerSection.gsub(
        /(<b>The\s*)?Charge(:)?(s)?(d)?(<\/b>)?:/,
        '</span>\\0<span class="charges">'
    )

    prisonerSection = prisonerSection.gsub(
        /Place(.*)of(.*)[dD].*etention(<\/b>)?:/m,
        '</span>\\0<span class="place-of-detention">'
    )

    prisonerSection = prisonerSection.gsub(
        /(Case\s*)?(b)?(B)?ackground(<\/b>)?:/,
        '</span>\\0<span class="background">'
    )

    return prisonerSection
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

def cleanName( name, prisNum )
    name = name.to_s

    ## Remove numbers
    name = name.gsub(/#{prisNum}\./, '')

    name = cleanValue( name )

    return name
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
    dateOfArrest = prisonerSection.css('.date-of-arrest')
    dateOfDetention = prisonerSection.css('.date-of-detention')
    dateOfPretrialDetention = prisonerSection.css('.date-of-pretrial-detention')

    if !dateOfArrest.empty?
        row.push( cleanDate(dateOfArrest))
        row.push( 'Arrest' )
        return row
    elsif !dateOfDetention.empty?
        row.push( cleanDate(dateOfDetention))
        row.push( 'Detention' )
        return row
    elsif !dateOfPretrialDetention.empty?
        row.push( cleanDate(dateOfPretrialDetention))
        row.push( 'Pretrial Detention' )
        return row
    end

    return row

end

def getRowFromPrisonerSection( prisonerSection, prisNum, prisTypeNum )
    row = []

    prisonerSection = wrapDataValues( prisNum, prisonerSection )

    #Remove tags within spans
    prisonerSection = prisonerSection.gsub(/<span class="charges"><\/b>/, '<span class="charges">')

    prisonerSection = Nokogiri::HTML( prisonerSection )
    prisonerSection.encoding = 'utf-8'

    row.push(prisNum)

    name = cleanName(prisonerSection.css('.prisoner-name'), prisNum)
    row.push(name)
    row.push( getPrisonerType( prisTypeNum ))
    row = pushDateAndDateType( row, prisonerSection )
    row.push( cleanCharges( prisonerSection.css('.charges')))

    return row;
end

def getRowsFromPrisonerSections( prisonerSectionsByType )
    rows = []
    prisTypeNum = 1
    prisNum = 1

    prisonerSectionsByType.each do |prisonerSectionsOneType|
        prisonerSectionsOneType.each do |prisonerSection|
            rows.push( getRowFromPrisonerSection( prisonerSection, prisNum, prisTypeNum ))
            prisNum+=1
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

require_relative 'prisonerSection.rb'

prisoner1 = PrisonerSection.new('hello')
puts prisoner1.getTextSection
