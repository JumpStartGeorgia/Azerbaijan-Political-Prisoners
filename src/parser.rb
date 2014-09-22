require 'Nokogiri'
require 'csv'

def nameXPath(prisNumber)
    return '//b[starts-with(normalize-space(.), "' + prisNumber.to_s + '.")
        and not(contains(normalize-space(.), "' + (prisNumber + 1).to_s + '."))
        and not(contains(normalize-space(.), "Public Union"))]'
end

def getName(list, i)
    name = list.xpath(nameXPath(i)).text

    stringsToRemove = [i.to_s + '.', ':', 'Date of arrest', 'Date of Detention', 'Date of detention', 'Detention date']

    stringsToRemove.each do |string|
        name.gsub! string, ''
    end

    return name.lstrip.rstrip
end

def getPrisonerSection(list, i)
    currentPrisonerNumber = i
    nextPrisonerNumber = i + 1

    currentPrisonerName = '//b[starts-with(normalize-space(.), "' + currentPrisonerNumber.to_s + '.") and not(contains(normalize-space(.), "' + (currentPrisonerNumber + 1).to_s + '.")) and not(contains(normalize-space(.), "Public Union"))]'

    nodesAfterCurrentPrisonerName = currentPrisonerName + '/following-sibling::node()'
    nodesBeforeNextPrisonerName = '//b[starts-with(normalize-space(.), "' + nextPrisonerNumber.to_s + '.") and not(contains(normalize-space(.), "' + (nextPrisonerNumber + 1).to_s + '.")) and not(contains(normalize-space(.), "Public Union"))]/preceding-sibling::node()'

    prisonerSectionXpath = currentPrisonerName + ' | ' + nodesAfterCurrentPrisonerName + '[count(.|' + nodesBeforeNextPrisonerName + ') = count(' + nodesBeforeNextPrisonerName + ')]'

    prisonerSection = Nokogiri::HTML( list.xpath( prisonerSectionXpath ).to_s )

    puts prisonerSectionXpath
    puts prisonerSection
    puts '\n\nPrisoner Section class: ' + prisonerSection.class.to_s

    return prisonerSection
end

def getCsvFromHtml(html_path, csv_path)
    #Prepare list
    list = Nokogiri::HTML(open(html_path).read)
    list.encoding = 'utf-8'

    rows = []
    list.xpath('//br').remove()

    (1..98).each do |i|
        name = getName(list, i)

        prisonerSection = ''
        dateArrest = ''

        if i == 1
            prisonerSection = getPrisonerSection(list, i)
            #dateArrest = prisonerSection.at( 'b:contains("Date of arrest:")' )
            dateArrest = prisonerSection.xpath( '//b[contains(normalize-space(.), "Date of")]/following-sibling::text()[1]')
        end

        rows.push([name, dateArrest])
    end

    #Write to file
    CSV.open(csv_path, 'wb') do |csv|
        #Each row should have the first name of the person, followed by the last name
        csv << ['Name', 'Type of Person', 'Date of Arrest', 'Charges', 'Place of Detention', 'Background Description', 'Picture']

        rows.each do |row|
            csv << row
        end

    end
end

getCsvFromHtml(File.dirname(__FILE__) + '/../input/list.html', File.dirname(__FILE__) + '/../output/output.csv')
#getCsvFromHtml( File.dirname(__FILE__) + '/../input/cleanList.html', File.dirname(__FILE__) + '/../output/cleanOutput.csv' )

