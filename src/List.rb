require_relative 'PrisonerType.rb'

class List
    def initialize(input_path)
        contents = openListFromPath(input_path)
        @input_path, @contents = input_path, prepareContents(contents)
    end

    def getPrisonerTypes
        return @prisonerTypes
    end

    def findPrisonerTypes
        contents = getContentsAsNokogiri()

        prisonerTypes = []
        ('A'..'G').each do |letter|
            prisonerType = PrisonerType.new( contents.css( '#' + letter + '-prisoner-type' ).to_s, letter )
            prisonerTypes.push( prisonerType )
        end
        @prisonerTypes = prisonerTypes
    end

    def getContentsAsNokogiri
        nokogiriContents = Nokogiri::HTML(@contents)
        nokogiriContents.encoding = 'utf-8'
        return nokogiriContents
    end

    def openListFromPath( input_path )
        file = File.open(input_path, "rb")
        list = file.read
        file.close

        return list;
    end

    def prepareContents(contents)
        contents = removePageRelatedTags( contents )
        contents = removeUnnecessaryTags( contents )
        contents = wrapPrisonerTypes( contents )
        return contents
    end

    def removePageRelatedTags( contents )
        (1..92).each do |i|
            pageRegex = '<a name=' + i.to_s + '><\/a>(?:' + i.to_s + ')?'

            contents = contents.gsub!(/#{pageRegex}/, '')

            if (!contents)
                raise 'Did not find tags related to page #' + i.to_s + ' to remove from list. Regex search: ' + pageRegex
            end
        end

        return contents
    end

    def removeUnnecessaryTags( contents )
        contents = Nokogiri::HTML( contents )
        contents.encoding = 'utf-8'

        contents.xpath('//br').remove()
        contents.xpath('//hr').remove()

        contents = contents.to_s
        return contents
    end

    def wrapPrisonerTypes( contents )
        ('A'..'G').each do |letter|
            if letter == 'A'
                contents = contents.gsub( /<b>#{letter}\./, '<div id="' + letter + '-prisoner-type"> \\0' )
            elsif letter == 'G'
                contents = contents.gsub( /<b>#{letter}\./, '</div><div id="' + letter + '-prisoner-type"> \\0' )
                contents = contents.gsub( /<\/body>/, '</div></body>')
            else
                contents = contents.gsub( /<b>#{letter}\./, '</div><div id="' + letter + '-prisoner-type"> \\0' )
            end
        end

        return contents
    end

    def writePrisonerValuesToOutput( output_path )
        CSV.open( output_path, 'wb') do |csv|
            csv << ['ID', 'Name', 'Type of Prisoner', 'Date', 'Type of Date','Charges', 'Place of Detention', 'Background Description', 'Picture']

            @prisonerTypes.each do |prisonerType|
                prisoners = prisonerType.getPrisoners
                prisoners.each do |prisoner|
                    #if prisoner.getId == 5
                    #    puts prisoner
                    #end

                    csv << [prisoner.getId, prisoner.getName, prisonerType.getName, prisoner.getDate, prisoner.getDateType, prisoner.getCharges, prisoner.getPlaceOfDetention, prisoner.getBackground]
                end
            end
        end
    end
end