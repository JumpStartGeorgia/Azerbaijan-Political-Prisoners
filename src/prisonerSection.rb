require 'Nokogiri'

class Prisoner
    def initialize(id, wholeText)
        @id = id

        wrappedText = wrapDataValues( wholeText )
        @wholeText = wrappedText
    end

    def to_s
        puts 'Prisoner ID: ' + @id.to_s
        puts ''
        puts 'Whole Text: '
        puts @wholeText
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

    def setName=(name)
        @name = name
    end

    def getDateType
        return @dateType
    end

    def setDateType=(dateType)
        @dateType = dateType
    end

    def cleanAndSetName(name)
        name = name.to_s

        ## Remove numbers
        name = name.gsub(/#{@id}\./, '')

        name = cleanValue( name )

        self.setName=(name)
    end

    def getWholeTextAsNokogiri
        return Nokogiri::HTML(@wholeText)
    end

    def wrapDataValues( wholeText )
        wholeText = wholeText.gsub(
            /<b>\s*#{@id}\./,
            '<span class="prisoner-name">\\0'
        )

        arrestRegexPatterns = ['Date of arrest:', 'Date of arrest\s*<\/b>:']

        arrestRegexPatterns.each do |pattern|
            wholeText = wholeText.gsub(
                /#{pattern}/,
                '</span>\\0<span class="date-of-arrest">'
            )
        end

        detentionRegexPatterns = ['Detention date:', 'Date of Detention:', 'Date of detention:', 'Date of Detention</b>:']

        if !wholeText.scan('detention decision was made on').empty?
            detentionRegexPatterns.each do |pattern|
                wholeText = wholeText.gsub(
                    /#{pattern}/,
                    '</span>\\0<span class="date-of-pretrial-detention">'
                )
            end
        else
            detentionRegexPatterns.each do |pattern|
                wholeText = wholeText.gsub(
                    /#{pattern}/,
                    '</span>\\0<span class="date-of-detention">'
                )
            end
        end

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