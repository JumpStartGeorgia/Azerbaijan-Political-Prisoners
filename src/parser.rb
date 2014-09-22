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

def wrapPrisonerSections( list )
    list = Nokogiri::HTML( list )

    typeA = list.css( '#A-prisoner-type' )


    return list.to_s

    # Get Xpath prisoner TYPE sections
    # Convert each prisoner TYPE section to string
    # Add structure of prisoner sections to prisoner Type sections
    # Replace the original Xpath prisoner TYPE sections with the new structured XPath Prisoner TYPE Sections in the list
end

def addStructureToList( list )
    list = list.to_s

    list = wrapPrisonerTypeSections( list )
    list = wrapPrisonerSections( list )

    list = Nokogiri::HTML( list )

    return list
end

def getRowsFromList( list, rows )
    rows.push(['Nathan Shane', 'Not a prisoner', 'Never', 'No Charges', 'Jumpstart', 'quite a description', 'heres my picture'])

    return rows
end

def writeRowsToOutput( rows, output_path )
    CSV.open( output_path, 'wb') do |csv|
        #Each row should have the first name of the person, followed by the last name
        csv << ['Name', 'Type of Prisoner', 'Date of Arrest', 'Charges', 'Place of Detention', 'Background Description', 'Picture']

        rows.each do |row|
            csv << row
        end
    end
end

def outputDataFromHtmlList(input_path, output_path)
    rows = []

    list = prepareList( input_path )
    list = addStructureToList( list )
    rows = getRowsFromList( list, rows )

    writeRowsToOutput( rows, output_path )
end

input_path = File.dirname(__FILE__) + '/../input/list.html'
output_path = File.dirname(__FILE__) + '/../output/output.csv'

outputDataFromHtmlList( input_path, output_path )


