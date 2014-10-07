class PrisonerSubtype
    def initialize(wholeText, letter, prisonerType)
        @prisonerType = prisonerType
        wholeText = wrapPrisoners(wholeText)
        wholeText = wrapName(wholeText, letter)
        @wholeText = wrapDescription(wholeText)

        @name = findName()
        @description = findDescription()
    end

    def getName
        return @name
    end

    def getDescription
        return @description
    end

    def findName
        @name = self.getWholeTextAsNokogiri.css('.subtypeName')[0].content.to_s
    end

    def findDescription
        description = self.getWholeTextAsNokogiri.css('.subtypeDescription')[0].content.to_s
        description = description.strip()

        if @prisonerType.getName == 'Human Rights Defenders'
            puts @wholeText
        end
        if description == ''
            description = 'No Subtype Description'
        end
        @description = description
    end

    def getPrisoners
        return @prisoners
    end

    def to_s
        puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
        puts ''
        puts 'Prisoner Subtype Name: ' + @name
        puts ''
        puts 'Prisoner Subtype Description: ' + @description
        puts ''
        puts 'Whole Text: ' + @wholeText
        puts ''
        puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
    end

    def getWholeTextAsNokogiri
        nokogiri_text = Nokogiri::HTML(@wholeText)
        nokogiri_text.encoding = 'utf-8'
        return nokogiri_text
    end

    def findPrisoners
        wholeText = getWholeTextAsNokogiri()

        prisoners = []
        (1..98).each do |j|
            prisonerText = wholeText.css('#prisoner-' + j.to_s).to_s
            if prisonerText.length != 0
                prisoner = Prisoner.new( j, self, self, prisonerText )
                prisoners.push( prisoner )
            end
        end

        @prisoners = prisoners
    end

    def wrapPrisoners(wholeText)
        firstPrisonerAlreadyFound = false

        (1..98).each do |prisNum|
            regex = wholeText.scan( /<b>\s*#{prisNum}\./ )

            if !regex.empty?
                if (!firstPrisonerAlreadyFound)
                    wholeText = wholeText.gsub( /<b>\s*#{prisNum}\./, '<div id="prisoner-' + prisNum.to_s + '"> \\0')
                    firstPrisonerAlreadyFound = true
                else
                    wholeText = wholeText.gsub( /<b>\s*#{prisNum}\./, '</div><div id="prisoner-' + prisNum.to_s + '"> \\0')
                end
            end
        end

        return wholeText
    end

    def wrapName(wholeText, letter)
        # Human Rights Defenders Section b has no bold tag, so special case must be included in order to find it
        if @prisonerType.getName == 'Human Rights Defenders' and letter == 'b'
            wholeText = wholeText.gsub( /b.  Other cases/, '<span class="subtypeName">\\0</span>')
        else
            wholeText = wholeText.gsub( /<b>\s*#{letter}\.(.*?)<\/b>/, '<span class="subtypeName">\\0</span>')
        end

        return wholeText
    end

    def wrapDescription(wholeText)
        wholeText = wholeText.gsub( /<span class="subtypeName">(.*?)<\/span>/, '\\0<span class="subtypeDescription">')
        wholeText = wholeText.sub( /<div id="prisoner-/, '</span>\\0')

        return wholeText
    end
end