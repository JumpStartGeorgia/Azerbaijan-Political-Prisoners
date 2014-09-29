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

    def setName=(uncleanName)
        @name = cleanName(uncleanName)
    end

    def cleanName(name)


        return name;
    end
end