require 'Nokogiri'
require 'csv'

#def nameXPath(prisNumber)
#    return '//b[starts-with(normalize-space(.), "' + prisNumber.to_s + '.")
#        and not(contains(normalize-space(.), "' + (prisNumber + 1).to_s + '."))
#        and not(contains(normalize-space(.), "Public Union"))]'
#end
#
#def getName(list, i)
#    name = list.xpath(nameXPath(i)).text
#
#    stringsToRemove = [i.to_s + '.', ':', 'Date of arrest', 'Date of Detention', 'Date of detention', 'Detention date']
#
#    stringsToRemove.each do |string|
#        name.gsub! string, ''
#    end
#
#    return name.lstrip.rstrip
#end
#
#def getPrisonerSection(list, i)
#    currentPrisonerNumber = i
#    nextPrisonerNumber = i + 1
#
#    currentPrisonerName = '//b[starts-with(normalize-space(.), "' + currentPrisonerNumber.to_s + '.") and not(contains(normalize-space(.), "' + (currentPrisonerNumber + 1).to_s + '.")) and not(contains(normalize-space(.), "Public Union"))]'
#
#    nodesAfterCurrentPrisonerName = currentPrisonerName + '/following-sibling::node()'
#    nodesBeforeNextPrisonerName = '//b[starts-with(normalize-space(.), "' + nextPrisonerNumber.to_s + '.") and not(contains(normalize-space(.), "' + (nextPrisonerNumber + 1).to_s + '.")) and not(contains(normalize-space(.), "Public Union"))]/preceding-sibling::node()'
#
#    prisonerSectionXpath = currentPrisonerName + ' | ' + nodesAfterCurrentPrisonerName + '[count(.|' + nodesBeforeNextPrisonerName + ') = count(' + nodesBeforeNextPrisonerName + ')]'
#
#    prisonerSection = Nokogiri::HTML(list.xpath(prisonerSectionXpath).to_s)
#
#    puts prisonerSectionXpath
#    puts prisonerSection
#    puts '\n\nPrisoner Section class: ' + prisonerSection.class.to_s
#
#    return prisonerSection
#end
#
#def getCsvFromHtml(html_path, csv_path)
#    #Prepare list
#    list = Nokogiri::HTML(open(html_path).read)
#    list.encoding = 'utf-8'
#
#    rows = []
#    list.xpath('//br').remove()
#
#    (1..98).each do |i|
#        name = getName(list, i)
#
#        prisonerSection = ''
#        dateArrest = ''
#
#        if i == 1
#            prisonerSection = getPrisonerSection(list, i)
#            #dateArrest = prisonerSection.at( 'b:contains("Date of arrest:")' )
#            dateArrest = prisonerSection.xpath('//b[contains(normalize-space(.), "Date of")]/following-sibling::text()[1]')
#        end
#
#        rows.push([name, dateArrest])
#    end
#
#    #Write to file
#    CSV.open(csv_path, 'wb') do |csv|
#        #Each row should have the first name of the person, followed by the last name
#        csv << ['Name', 'Type of Person', 'Date of Arrest', 'Charges', 'Place of Detention', 'Background Description', 'Picture']
#
#        rows.each do |row|
#            csv << row
#        end
#
#    end
#end
#
#

def prepareList( input_path )
    list = Nokogiri::HTML( open(input_path).read )
    list.encoding = 'utf-8'
    list.xpath('//br').remove()

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
    prisonerSection = prisonerSection.gsub( /<b>\s*#{prisNum}\./, '<span class="prisoner-name">\\0')
    prisonerSection = prisonerSection.gsub( /Date of /, '</span>\\0<span class="date-of-arrest">')
    prisonerSection = prisonerSection.gsub( /Detention date:/, '</span>\\0<span class="date-of-arrest">')

    return prisonerSection
end

def cleanValue( name, prisNum )
    name = name.to_s

    ## Remove everything in tags
    name = name.gsub(/<(.|\n)*?>/, '')

    ## Remove numbers
    name = name.gsub(/#{prisNum}\./, '')
    name = name.strip()
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

def getRowsFromPrisonerSections( prisonerSectionsByType )
    rows = []
    prisTypeNum = 1
    prisNum = 1

    prisonerSectionsByType.each do |prisonerSectionsOneType|
        prisonerSectionsOneType.each do |prisonerSection|
            row = []

            prisonerSection = wrapDataValues( prisNum, prisonerSection )
            prisonerSection = Nokogiri::HTML( prisonerSection )

            #if prisNum == 85
            #    puts prisonerSection
            #end


            name = cleanValue(prisonerSection.css('.prisoner-name'), prisNum)
            row.push(name)
            row.push( getPrisonerType( prisTypeNum ))

            rows.push(row)
            prisNum+=1
        end
        prisTypeNum+=1
    end

    return rows
end

def writeRowsToOutput( rows, output_path )
    CSV.open( output_path, 'wb') do |csv|
        csv << ['Name', 'Type of Prisoner', 'Date of Arrest', 'Charges', 'Place of Detention', 'Background Description', 'Picture']

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


