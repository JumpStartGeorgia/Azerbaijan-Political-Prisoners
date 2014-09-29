require 'Nokogiri'

class Prisoner
    def initialize(id, wholeText)
        @id, @wholeText = id, wholeText
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
end