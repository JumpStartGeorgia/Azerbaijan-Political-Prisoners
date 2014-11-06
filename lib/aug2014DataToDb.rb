require 'csv'

module Aug2014DataToDb
    def self.migrateData
        self.destroyData

        outputTypes = []

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/prisoners.csv", "r") do |row|
            if $. != 1
                Prisoner.create(name: row[1])

                type = row[2]
                if !outputTypes.include? type
                    outputTypes.push(type)
                    Type.create(name: type)
                end
            end
        end

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/articles.csv", "r") do |row|
            if $. != 1
                Charge.create(
                    number: row[0],
                    criminal_code: row[1]
                )
            end
        end

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/placesOfDetention.csv", "r") do |row|
            if $. != 1
                Prison.create(name: row[0])
            end
        end
    end

    def self.destroyData
        Prisoner.destroy_all
        Charge.destroy_all
        Prison.destroy_all
        Type.destroy_all
    end
end