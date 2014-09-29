require 'Nokogiri'

require_relative 'clean.rb'

class Prisoner
    def initializeDate
        wholeText = self.getWholeTextAsNokogiri

        dateOfArrest = wholeText.css('.date-of-arrest')
        dateOfDetention = wholeText.css('.date-of-detention')
        dateOfPretrialDetention = wholeText.css('.date-of-pretrial-detention')

        if !dateOfArrest.empty?
            date = dateOfArrest
        elsif !dateOfDetention.empty?
            date = dateOfDetention
        elsif !dateOfPretrialDetention.empty?
            date = dateOfPretrialDetention
        end

        date = cleanDate(date)

        return date
    end

    def initializeData
        wholeText = self.getWholeTextAsNokogiri

        name = cleanName(wholeText.css('.prisoner-name'))
        date = self.initializeDate
        charges = cleanCharges( wholeText.css('.charges'))

        return name, date, charges
    end

    def initialize(id, wholeText)
        @id = id
        @wholeText = wrapDataValues( wholeText )
        @name, @date, @charges = self.initializeData
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

    def setDateType=(dateType)
        @dateType = dateType
    end

    def getCharges
        return @charges
    end

    def getWholeTextAsNokogiri
        return Nokogiri::HTML(@wholeText)
    end

    def wrapDate( wholeText )
        arrestRegexPatterns = ['Date of arrest:', 'Date of arrest\s*<\/b>:']
        detentionRegexPatterns = ['Detention date:', 'Date of Detention:', 'Date of detention:', 'Date of Detention</b>:']

        arrestRegexPatterns.each do |pattern|
            textMarkedWithDate = wholeText.gsub!(
                /#{pattern}/,
                '</span>\\0<span class="date-of-arrest">'
            )

            if (textMarkedWithDate)
                self.setDateType=('Arrest')
                return textMarkedWithDate
            end
        end

        detentionRegexPatterns.each do |pattern|
            if !wholeText.scan(/#{pattern}/).empty?
                if !wholeText.scan('detention decision was made on').empty?
                    self.setDateType=('Pretrial Detention')

                    return wholeText.gsub(
                        /#{pattern}/,
                        '</span>\\0<span class="date-of-pretrial-detention">'
                    )
                else
                    self.setDateType=('Detention')

                    return wholeText.gsub(
                        /#{pattern}/,
                        '</span>\\0<span class="date-of-detention">'
                    )
                end
            end
        end

        return wholeText
    end

    def wrapDataValues( wholeText )
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

        wholeText = wholeText.gsub(
            /(Case\s*)?(b)?(B)?ackground(<\/b>)?:/,
            '</span>\\0<span class="background">'
        )

        #Remove tags within spans
        wholeText = wholeText.gsub(/<span class="charges"><\/b>/, '<span class="charges">')

        return wholeText
    end
end