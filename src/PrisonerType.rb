class PrisonerType
    def initialize(wholeText, letter)
        @wholeText, @name = wrapPrisoners(wholeText), setNameFromLetter(letter)
    end

    def getWholeText
        return @wholeText
    end

    def getName
        return @name
    end

    def getWholeTextAsNokogiri
        nokogiri_text = Nokogiri::HTML(@wholeText)
        nokogiri_text.encoding = 'utf-8'
        return nokogiri_text
    end
    
    def setNameFromLetter(letter)
        if letter == 'A'
            name = 'Journalists and Bloggers'
        elsif letter == 'B'
            name = 'Human Rights Defenders'
        elsif letter == 'C'
            name = 'Youth Activists'
        elsif letter == 'D'
            name = 'Politicians'
        elsif letter == 'E'
            name = 'Religious Activists'
        elsif letter == 'F'
            name = 'Lifetime Prisoners'
        elsif letter == 'G'
            name = 'Other Cases'
        end

        return name
    end

    def wrapPrisoners( wholeText )
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

        wholeText = wholeText + '</div>'

        return wholeText
    end


end