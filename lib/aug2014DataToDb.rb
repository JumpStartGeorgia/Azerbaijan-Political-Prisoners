require 'csv'
require 'date'

module Aug2014DataToDb
  def self.migrate
    destroyData

    CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/prisoners.csv", 'r') do |row|
      if $INPUT_LINE_NUMBER != 1
        prisoner = Prisoner.new
        prisoner.name = row[1]

        portrait_path = "#{Rails.root}/lib/aug2014PdfParser/portraits/pris" + row[0] + '-portrait1.jpg'
        if File.file?(portrait_path)
          portrait = File.open(portrait_path)
          prisoner.portrait = portrait
          portrait.close
        end

        prisoner.save

        type_name = row[2]
        # There is no spreadsheet of unique types, so this ensures that the same type is not created as a tag twice
        Tag.find_or_create_by(name: type_name) if type_name != 'Other Cases'
      end
    end

    CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/articles.csv", 'r') do |row|
      if $INPUT_LINE_NUMBER != 1
        CriminalCode.find_or_create_by(name: row[1])

        Article.create(
          number: row[0],
          criminal_code: CriminalCode.where(name: row[1]).first
        )
      end
    end

    CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/placesOfDetention.csv", 'r') do |row|
      Prison.create(name: row[0]) if $INPUT_LINE_NUMBER != 1
    end

    CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/subtypes.csv", 'r') do |row|
      if $INPUT_LINE_NUMBER != 1
        tag_name = row[1].strip
        if tag_name != 'Other cases'
          tag = Tag.new
          tag.name = tag_name
          tag.description = row[3] if row[3] != 'No Subtype Description'
          tag.save
        end
      end
    end

    CSV.foreach("#{Rails.root}/lib/aug2014PdfParser/output/prisoners.csv", 'r') do |row|
      if $INPUT_LINE_NUMBER != 1
        incident = createIncident(row)
        createCharges(row, incident.id)
      end
    end
  end

  def self.createIncident(row)
    incident = Incident.new
    incident.prisoner = Prisoner.where(name: row[1]).first
    incident.date_of_arrest = Date.strptime(row[4], '%d/%m/%Y')
    incident.description_of_arrest = row[7] if row[7] != 'Not Listed'

    incident.prison = Prison.where(name: row[6]).first if row[6] != 'Not Listed'

    incident.tags << Tag.where(name: row[2]).first if row[2] != 'Other Cases'

    tag_name = row[3].strip
    if tag_name != 'No Subtype' && tag_name != 'Other cases'
      incident.tags << Tag.where(name: tag_name).first
    end

    incident.save

    incident.prisoner.save

    incident
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
    Incident.destroy_all
    Charge.destroy_all
  end
end
