class PrisonerSection
    def initialize(id, wholeSection)
        @id, @wholeSection = id, wholeSection
    end

    def getId
        return @id
    end

    def getWholeSection
        return @wholeSection
    end
end