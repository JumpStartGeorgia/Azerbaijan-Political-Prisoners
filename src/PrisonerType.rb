class PrisonerType
    def initialize(wholeText)
        @wholeText = wrapPrisoners(wholeText)
    end

    def getWholeText
        return @wholeText
    end

    def getWholeTextAsNokogiri
        nokogiri_text = Nokogiri::HTML(@wholeText)
        nokogiri_text.encoding = 'utf-8'
        return nokogiri_text
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