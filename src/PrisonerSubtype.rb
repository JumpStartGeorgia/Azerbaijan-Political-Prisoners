class PrisonerSubtype
    def initialize(wholeText)
        @wholeText = wholeText
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
        @name = 'findName function has not been completed yet'
    end

    def findDescription
        @description = 'findDescription function has not been completed yet'
    end

    def getPrisoners
        return @prisoners
    end

    def findPrisoners
        prisoners = []
        @prisoners = prisoners
    end
end