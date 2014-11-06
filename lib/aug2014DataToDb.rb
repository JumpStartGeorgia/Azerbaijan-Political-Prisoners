module Aug2014DataToDb
    def self.migratePrisoners
        Prisoner.create(name: 'Nathan')
    end
end