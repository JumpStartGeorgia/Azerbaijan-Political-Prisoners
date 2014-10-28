require_relative 'clean.rb'
require_relative 'Article.rb'

class Prisoner
    def initializeDateAndDateType
        wholeText = self.getWholeTextAsNokogiri

        dateOfArrest = wholeText.css('.date-of-arrest')
        dateOfDetention = wholeText.css('.date-of-detention')
        dateOfPretrialDetention = wholeText.css('.date-of-pretrial-detention')

        if !dateOfArrest.empty?
            date = dateOfArrest
            dateType = 'Arrest'
        elsif !dateOfDetention.empty?
            date = dateOfDetention
            dateType = 'Detention'
        elsif !dateOfPretrialDetention.empty?
            date = dateOfPretrialDetention
            dateType = 'Pretrial Detention'
        end

        date = formatDate( cleanDate(date, @id), @id)

        return date, dateType
    end

    def checkNotListedValue(value, notListedArray, label)
        if value.length == 0
            if notListedArray.include? @id
                value = 'Not Listed'
            else
                raise 'Prisoner ' + @id.to_s + ' has no ' + label + ' (not in approved array of prisoners with no ' + label + ')'
            end
        end

        return value
    end

    def initializeData
        wholeText = self.getWholeTextAsNokogiri

        name = cleanName(wholeText.css('.prisoner-name').to_s)
        if name.length == 0
            raise 'Prisoner ID ' + @id + ' name not found'
        end

        date, dateType = self.initializeDateAndDateType
        charges = separateCharges(cleanCharges( wholeText.css('.charges').to_s))

        placeOfDetention = cleanPlaceOfDetention( wholeText.css('.place-of-detention').to_s, @id)
        placeOfDetention = checkNotListedValue(placeOfDetention, [27, 78, 79, 80, 81], 'place of detention')

        background = cleanBackground( wholeText.css('.background').to_s, @id )
        background = checkNotListedValue(background, (35..49).to_a.concat((87..89).to_a), 'background' )

        return name, date, dateType, charges, placeOfDetention, background
    end

    def initialize(id, prisonerType, prisonerSubtype, wholeText)
        @id, @prisonerType, @prisonerSubtype = id, prisonerType, prisonerSubtype
        @wholeText = prepareText( wholeText )
        @name, @date, @dateType, @charges, @placeOfDetention, @background = self.initializeData
        approveHttpPattern()
    end

    def to_s
        puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
        puts ''
        puts 'ID: ' + @id.to_s
        puts ''
        puts 'Whole Text: ' + @wholeText
        puts ''
        puts 'ID: ' + @id.to_s
        puts ''
        puts 'Name: ' + @name
        puts ''
        puts 'Date: ' + @date
        puts ''
        puts 'Date Type: ' + @dateType
        puts ''
        puts 'Charges: ' + @charges
        if (@placeOfDetention)
            puts ''
            puts 'Place of Detention: ' + @placeOfDetention
        end
        if (@background)
            puts ''
            puts 'Background: ' + @background
        end
        puts ''
        puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
    end

    def getId
        return @id
    end

    def getPrisonerType
        return @prisonerType
    end

    def getPrisonerSubtype
        return @prisonerSubtype
    end

    def getPrisonerSubtypeId
        if @prisonerSubtype == 'No Subtype'
            return @prisonerSubtype
        else
            return @prisonerSubtype.getId
        end
    end

    def getPrisonerSubtypeName
        if @prisonerSubtype == 'No Subtype'
            return @prisonerSubtype
        else
            return @prisonerSubtype.getName
        end
    end

    def getPrisonerSubtypeDescription
        if @prisonerSubtype == 'No Subtype'
            return @prisonerSubtype
        else
            return @prisonerSubtype.getDescription
        end
    end

    def getWholeText
        return @wholeText
    end

    def setWholeText=(wholeText)
        @wholeText = wholeText
    end

    def getName
        return @name
    end

    def getDate
        return @date
    end

    def getDateType
        return @dateType
    end

    def getCharges
        return @charges
    end

    def getPlaceOfDetention
        return @placeOfDetention
    end

    def getBackground
        return @background
    end

    def getWholeTextAsNokogiri
        nokogiri_text = Nokogiri::HTML(@wholeText)
        nokogiri_text.encoding = 'utf-8'
        return nokogiri_text
    end

    def wrapDate( wholeText )
        arrestRegexPatterns = ['Date of arrest:', 'Date of arrest\s*<\/b>:']
        detentionRegexPatterns = ['Detention date:', 'Date of Detention:', 'Date of detention:', 'Date of Detention</b>:']

        #Check for arrest date
        arrestRegexPatterns.each do |pattern|
            textMarkedWithDate = wholeText.gsub!(
                /#{pattern}/,
                '</span>\\0<span class="date-of-arrest">'
            )

            if (textMarkedWithDate)
                return textMarkedWithDate
            end
        end

        #Check for detention date
        detentionRegexPatterns.each do |pattern|
            if !wholeText.scan(/#{pattern}/).empty?
                if !wholeText.scan('detention decision was made on').empty?
                    return wholeText.gsub(
                        /#{pattern}/,
                        '</span>\\0<span class="date-of-pretrial-detention">'
                    )
                else
                    return wholeText.gsub(
                        /#{pattern}/,
                        '</span>\\0<span class="date-of-detention">'
                    )
                end
            end
        end

        return wholeText
    end

    def wrapBackground( wholeText )
        regexForBackgroundLabel = [
            '(Case\s*)?(b)?(B)?ackground(<\/b>)?:(\s*)?(<\/b>)?',
            '<b>Brief\s*Summary\s*of\s*the\s*Case:(\s*)?(<\/b>)?',
            #For prisoner ID 30
            'Background of person:'
        ]

        regexForBackgroundLabel.each do |regex|
            wholeText = wholeText.gsub(
                /#{regex}/,
                '</span>\\0<span class="background">'
            )
        end

        wholeText = wholeText + '</span>'

        return wholeText
    end

    def wrapValues( wholeText )
        wholeText = wholeText.gsub(
            /<b>\s*#{@id}\./,
            '<span class="prisoner-name">\\0'
        )

        wholeText = wrapDate( wholeText )

        wholeText = wholeText.gsub(
            /(<b>The\s*)?Charge(:)?(s)?(d)?(<\/b>)?:/,
            '</span>\\0<span class="charges">'
        )

        wholeText = wholeText.gsub(
            /Place(.*)of(.*)[dD].*etention(<\/b>)?:/m,
            '</span>\\0<span class="place-of-detention">'
        )

        wholeText = wrapBackground(wholeText)

        #Remove closing </b> tag after opening span tag
        wholeText = wholeText.gsub(/<span class="charges"><\/b>/, '<span class="charges">')
        wholeText = wholeText.gsub(/<span class="place-of-detention">\s*<\/b>/, '<span class="place-of-detention">')

        return wholeText
    end

    #Charges of prisoners 87-89 are formatted differently, using the words 'Article', 'Part' and 'Item'
    def reformatLifetimePrisoners(chargesText, regexArticleNumber)
        if (87..89).to_a.include? @id
            #Remove occurrence of 'Items' so that Articles and Parts only need to be combined
            chargesText = chargesText.gsub(/Article 145, Part 2, Items 1, 2, 5 and 6 .*?personal property\);/, 'Article 145.2.1 (); Article 145.2.2 (); Article 145.2.5 (); Article 145.2.6 ();')

            #Replace this formatting exception with the standard formatting for prisoners 87-89
            chargesText = chargesText.gsub('Part 3 of Article 220-1', 'Article 220-1, Part 3')

            chargesText = chargesText + ';'
            articleSections = chargesText.scan(/Article #{regexArticleNumber}.*?;/)

            articleSections.each do |articleSection|
                originalSection = articleSection.to_s
                articleNumber = articleSection.scan(/Article (#{regexArticleNumber})/)[0][0].to_s
                articleSection = articleSection.gsub(/Article #{regexArticleNumber}/, '')
                articleSection = articleSection.gsub(/#{regexArticleNumber} \(/, articleNumber + '.\\0')
                articleSection = 'Article ' + articleNumber + articleSection

                chargesText = chargesText.gsub(originalSection, articleSection)
            end
        end

        return chargesText
    end

    def editChargesText( chargesText, regexArticleNumber )
        chargesText = chargesText.gsub('Criminal Code (of 1960) ', '')

        #Remove 'of the Criminal Code' when it occurs between a number and an opening parenthesis
        chargesText = chargesText.gsub(/(#{regexArticleNumber}) of the Criminal Code\s?(\()/, '\\1 \\2')

        #Prisoners 35-37 remove extra -ci on the end of article 278
        chargesText = chargesText.gsub('278-ci', '278')

        #Prisoner 40 formatting exception
        chargesText = chargesText.gsub('274(', '274 (')
        chargesText = chargesText.gsub('278(', '278 (')

        #Prisoners 45-49 make Article 28 detectable by parser
        chargesText = chargesText.gsub('28, 214.2', '28 (), 214.2')

        #Prisoners 84-86 make article number detectable by parser
        chargesText = chargesText.gsub('Article 168.2 of the Criminal Code', 'Article 168.2 () of the Criminal Code')

        chargesText = reformatLifetimePrisoners(chargesText, regexArticleNumber)

        return chargesText
    end

    def separateCharges( chargesText )
        print = true

        if (87..89).to_a.include? @id
            criminalCode = '1960'
        else
            criminalCode = 'Current'
        end

        # Matches article numbers, including 167.2.2.1; 313; 28; 220-1
        regexArticleNumber = '(?:[0-9]|[\.\-])*[0-9]'

        if print
            puts '______________'
            puts 'Prisoner #' + @id.to_s
            puts ''
            puts 'CHARGES UNEDITED TEXT: ' + chargesText
            puts ''
        end

        chargesText = editChargesText( chargesText, regexArticleNumber )

        #if print
        #    puts ''
        #    puts 'CHARGES EDITED TEXT: ' + chargesText
        #    puts ''
        #end
        separatedCharges = chargesText.scan(/(#{regexArticleNumber}) \(/)

        charges = []
        separatedCharges.each_with_index do |articleNumber, index|
            articleNumber = articleNumber[0].to_s
            multipleOccurrencesOfSameCharge = false

            #Check for repeat occurrences of article and do not add article if it has already been added
            charges.each do |storedCharge|
                if storedCharge.getNumber == articleNumber
                    multipleOccurrencesOfSameCharge = true
                end
            end

            if !multipleOccurrencesOfSameCharge
                charges.push(Article.new(criminalCode, articleNumber))
                if print
                    puts 'Added Article: ' + (index + 1).to_s + ': ' + articleNumber
                end
            else
                if print
                    puts 'DID NOT ADD DUPLICATE Article: ' + articleNumber
                end
            end
        end
        if print
            puts ''
            puts '______________'
        end

        return charges
    end

    def prepareText( wholeText )
        wholeText = wholeText.gsub(/<div id="prisoner-#{@id}">/, '')
        wholeText = wholeText.gsub(/<\/div>/, '')
        wholeText = wrapValues(wholeText)

        return wholeText
    end

    def approveHttpPattern
        #If a prisoner text contains the pattern http:// and is not approved, prints it out
        pattern = 'http'
        numberHttpStrings = @wholeText.scan(/#{pattern}/).length
        approvedHttpPrisoners = [3, 4, 5, 6, 83]

        if numberHttpStrings > 0
            if !approvedHttpPrisoners.include? @id
                puts self
                puts 'Prisoner #' + @id.to_s + ' has ' + numberHttpStrings.to_s + ' "' + pattern + '" patterns'
            end
        end
    end
end