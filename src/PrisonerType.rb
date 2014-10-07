require_relative 'Prisoner.rb'
require_relative 'PrisonerSubtype.rb'

class PrisonerType
    def initialize(wholeText, letter)
        @name = setNameFromLetter(letter)
        wholeText = wrapPrisoners(wholeText)
        @wholeText = wrapSubtypes(wholeText)
    end

    def getWholeText
        return @wholeText
    end

    def getName
        return @name
    end

    def getPrisoners
        return @prisoners
    end

    def findSubtypes
        subtypes = []
        prisonerTypeText = self.getWholeTextAsNokogiri

        ('a'..'g').each do |letter|
            subtypeText = prisonerTypeText.css('#subtype-' + letter).to_s

            if subtypeText.length != 0
                subtype = PrisonerSubtype.new(subtypeText)
                subtypes.push(subtype)
            end
        end

        @subtypes = subtypes
    end

    def findPrisoners
        prisoners = []
        prisonerTypeText = self.getWholeTextAsNokogiri

        #Find the prisoners contained in subtypes
        @subtypes.each do |subtype|
            subtype.findPrisoners
            prisoners.concat(subtype.getPrisoners)
        end

        #If a prisoner is not in a subtype, then look for it in the whole text of the prisonerType
        (1..98).each do |j|
            prisonerAlreadyFound = false
            prisoners.each do |prisoner|
                if j == prisoner.getId
                    prisonerAlreadyFound = true
                end
            end

            if !prisonerAlreadyFound
                prisonerText = prisonerTypeText.css('#prisoner-' + j.to_s).to_s
                if prisonerText.length != 0
                    prisoner = Prisoner.new( j, self, 'None', prisonerText )
                    prisoners.push( prisoner )
                end
            end
        end

        @prisoners = prisoners
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

    def wrapSubtypes( wholeText )


        return wholeText
    end
end