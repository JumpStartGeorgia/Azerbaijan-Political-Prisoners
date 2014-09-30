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

        date = cleanDate(date)

        return date, dateType
    end

    def initializeData
        wholeText = self.getWholeTextAsNokogiri

        name = cleanName(wholeText.css('.prisoner-name'))
        date, dateType = self.initializeDateAndDateType
        charges = cleanCharges( wholeText.css('.charges'))

        return name, date, dateType, charges
    end

    def initialize(id, prisonerType, wholeText)
        @id, @prisonerType = id, prisonerType
        @wholeText = wrapValues( wholeText )
        @name, @date, @dateType, @charges = self.initializeData
    end

    def to_s
        puts 'Prisoner ID: ' + @id.to_s
        puts ''
        puts 'Whole Text: '
        puts @wholeText
        puts ''
        puts 'ID: ' + @id.to_s
        puts 'Name: ' + @name
        puts 'Date: ' + @date
        puts 'Date Type: ' + @dateType
        puts 'Charges: ' + @charges
        puts ''
        puts ''
    end

    def getId
        return @id
    end

    def getPrisonerType
        return @prisonerType
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

        #Remove incomplete tags within charges span
        wholeText = wholeText.gsub(/<span class="charges"><\/b>/, '<span class="charges">')

        wholeText = wholeText.gsub(
            /Place(.*)of(.*)[dD].*etention(<\/b>)?:/m,
            '</span>\\0<span class="place-of-detention">'
        )

        wholeText = wholeText.gsub(
            /(Case\s*)?(b)?(B)?ackground(<\/b>)?:/,
            '</span>\\0<span class="background">'
        )

        return wholeText
    end
end