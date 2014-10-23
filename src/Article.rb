class Article
    def initialize(criminalCode, number)
        @criminalCode = criminalCode
        @number = number
        @description = 'Description Function still not defined'
    end

    def getCriminalCode
        return @criminalCode
    end

    def getNumber
        return @number
    end

    def getDescription
        return @description
    end
end