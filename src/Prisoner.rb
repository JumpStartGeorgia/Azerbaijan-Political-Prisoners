require_relative 'clean.rb'

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
                raise 'Prisoner ' + @id.to_s + ' has no ' + label + ' (not in approved array)'
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
        charges = cleanCharges( wholeText.css('.charges').to_s)

        placeOfDetention = cleanPlaceOfDetention( wholeText.css('.place-of-detention').to_s, @id)
        placeOfDetention = checkNotListedValue(placeOfDetention, [27, 78, 79, 80, 81], 'place of detention')

        background = cleanBackground( wholeText.css('.value').to_s )
        background = checkNotListedValue(background, (35..49).to_a.concat((87..89).to_a), 'background' )

        return name, date, dateType, charges, placeOfDetention, background
    end

    def initialize(id, prisonerType, prisonerSubtype, wholeText)
        @id, @prisonerType, @prisonerSubtype = id, prisonerType, prisonerSubtype
        @wholeText = prepareText( wholeText )
        @name, @date, @dateType, @charges, @placeOfDetention, @background = self.initializeData
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
            '(Case\s*)?(b)?(B)?ackground(<\/b>)?:',
            '<b>Brief\s*Summary\s*of\s*the\s*Case:',
            #For prisoner ID 30
            'Background of person:'
        ]

        regexForBackgroundLabel.each do |regex|
            wholeText = wholeText.gsub(
                /#{regex}/,
                '</span>\\0<span class="value">'
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

    def prepareText( wholeText )
        wholeText = wholeText.gsub(/<div id="prisoner-#{@id}">/, '')
        wholeText = wholeText.gsub(/<\/div>/, '')
        wholeText = wrapValues(wholeText)

        return wholeText
    end
end