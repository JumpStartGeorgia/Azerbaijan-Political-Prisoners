require 'csv'
require 'date'

module Aug2014DataToDb
    def self.migrate
        self.destroyData

        outputTypes = []

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/prisoners.csv", "r") do |row|
            if $. != 1
                Prisoner.create(name: row[1])

                type = row[2]
                #There is no spreadsheet of unique types, so we ensure here that the same type is not created twice
                if !outputTypes.include? type
                    outputTypes.push(type)
                    Type.create(name: type)
                end
            end
        end

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/articles.csv", "r") do |row|
            if $. != 1
                if !CriminalCode.exists?(name: row[1])
                    CriminalCode.create(name: row[1])
                end

                Article.create(
                    number: row[0],
                    criminal_code: CriminalCode.where(name: row[1]).first
                )
            end
        end

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/placesOfDetention.csv", "r") do |row|
            if $. != 1
                Prison.create(name: row[0])
            end
        end

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/subtypes.csv", "r") do |row|
            if $. != 1
                subtype = Subtype.new
                subtype.name = row[1]
                subtype.type = Type.where(name: row[2]).first
                if row[3] != 'No Subtype Description'
                    subtype.description = row[3]
                end
                subtype.save
            end
        end

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/prisoners.csv", "r") do |row|
            if $. != 1
                incident = self.createIncident(row)
                self.createCharges(row, incident.id)
            end
        end
    end

    def self.createIncident(row)
        incident = Incident.new
        incident.prisoner = Prisoner.where(name: row[1]).first
        incident.date_of_arrest = Date.strptime(row[4], '%d/%m/%Y')
        if row[7] != 'Not Listed'
            incident.description_of_arrest = row[7]
        end
        incident.prison = Prison.where(name: row[6]).first
        incident.type = Type.where(name: row[2]).first

        if row[3] != 'No Subtype'
            incident.subtype = Subtype.where(name: row[3], type: incident.type).first
        end

        incident.save

        return incident
    end

    def self.createCharges(row, incidentId)
        chargeNumbers = row[5].split(',')
        chargeNumbers.each do |chargeNumber|
            Charge.create(incident: Incident.find(incidentId), article: Article.where(number: chargeNumber).first)
        end
    end


    def self.destroyData
        Prisoner.destroy_all
        Article.destroy_all
        CriminalCode.destroy_all
        Prison.destroy_all
        Type.destroy_all
        Subtype.destroy_all
        Incident.destroy_all
        Charge.destroy_all
    end
end