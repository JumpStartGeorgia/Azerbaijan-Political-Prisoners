class Prisoner
    def initialize(id, wholeSection)
        @id, @wholeSection = id, wholeSection
    end

    def getId
        return @id
    end

    def getWholeSection
        return @wholeSection
    end

    def getName
        return @name
    end

    def setName=(name)
        @name = name
    end

    def cleanAndSetName(name)
        name = name.to_s

        ## Remove numbers
        name = name.gsub(/#{@id}\./, '')

        name = cleanValue( name )

        self.setName=(name)
    end
end