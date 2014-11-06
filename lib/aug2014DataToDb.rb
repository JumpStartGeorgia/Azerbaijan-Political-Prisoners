require 'csv'

module Aug2014DataToDb
    def self.migratePrisoners
        Prisoner.destroy_all

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/prisoners.csv", "r") do |row|
            if $. != 1
                Prisoner.create(name: row[1])
            end
        end
    end
end