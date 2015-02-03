require 'csv'
require 'date'

module Aug2014DataToDb
    def self.migrate
        self.destroyData

        outputTypes = []
        outputTags = []

        CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/prisoners.csv", "r") do |row|
            if $. != 1
                prisoner = Prisoner.new
                prisoner.name = row[1]

                portrait_path = "#{Rails.root}/lib/aug2014PdfParser/portraits/pris" + row[0] + "-portrait1.jpg"
                if File.file?(portrait_path)
                  portrait = File.open(portrait_path)
                  prisoner.portrait = portrait
                  portrait.close
                end

                prisoner.save

                type_name = row[2]
                #There is no spreadsheet of unique types, so this ensures that the same type is not created as a tag twice
                if !outputTags.include? type_name and type_name != 'Other Cases'
                  outputTags.push(type_name)
                  Tag.create(name: type_name)
                end


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
            tag_name = row[1].strip
            if tag_name != 'Other cases'
              tag = Tag.new
              tag.name = tag_name
              if row[3] != 'No Subtype Description'
                  tag.description = row[3]
              end
              tag.save
            end
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

        if row[6] != 'Not Listed'
            incident.prison = Prison.where(name: row[6]).first
        end

        incident.type = Type.where(name: row[2]).first

        if row[3] != 'No Subtype'
            incident.subtype = Subtype.where(name: row[3], type: incident.type).first
        end

        if row[2] != 'Other Cases'
          incident.tags << Tag.where(name: row[2]).first
        end

        tag_name = row[3].strip
        if tag_name != 'No Subtype' and tag_name != 'Other cases'
          incident.tags << Tag.where(name: tag_name).first
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
        Tag.destroy_all
        Type.destroy_all
        Subtype.destroy_all
        Incident.destroy_all
        Charge.destroy_all
    end
end