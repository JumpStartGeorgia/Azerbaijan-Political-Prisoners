module Aug2014DataToDb
    def self.migratePrisoners
        Prisoner.destroy_all

        Prisoner.create(name: 'Nathan')
    end
end