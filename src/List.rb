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
        contents = getContentsAsNokogiri( @contents )

        prisonerTypes = []
        ('A'..'G').each do |letter|
            prisonerType = PrisonerType.new( contents.css( '#' + letter + '-prisoner-type' ).to_s, letter )
            prisonerTypes.push( prisonerType )
        end
        @prisonerTypes = prisonerTypes
    end

    def getContentsAsNokogiri( contents )
        nokogiriContents = Nokogiri::HTML(contents)
        nokogiriContents.encoding = 'utf-8'
        return nokogiriContents
    end

    def openListFromPath( input_path )
        file = File.open(input_path, "rb")
        list = file.read
        file.close

        return list
    end

    def prepareContents(contents)
        contents = removeSingleTagElements( contents )
        contents = removePageRelatedTags( contents )
        contents = removeBitLyLinks( contents )
        contents = removeLeftoverBadContent( contents )
        puts contents
        contents = wrapPrisonerTypes( contents )
        return contents
    end

    def removeSingleTagElements( contents )
        contents = getContentsAsNokogiri( contents )

        contents.xpath('//br').remove()
        contents.xpath('//hr').remove()

        contents = contents.to_s
        return contents
    end

    def removePageRelatedTags( contents )
        removeRegex = ''
        contents = contents.gsub!(/#{removeRegex}/, '')

        (1..92).each do |i|
            removeRegex = '<a name="' + i.to_s + '"><\/a>(?:<img src="list-'+ i.to_s + '_1.jpg">)?(?:\n)?(?:<img src="list-'+ i.to_s + '_2.jpg">)?(?:\n)?(?:' + i.to_s + ')?'
            contents = contents.gsub!(/#{removeRegex}/, '')

            if (!contents)
                raise 'Did not find tags related to page #' + i.to_s + ' to remove from list. Regex search: ' + removeRegex
            end
        end

        return contents
    end

    # Removes this sort of <a> tag:
    #<a href="http://bit.ly/1hiq3vA">38 http://bit.ly/1hiq3vA </a>
    #<a href="http://bit.ly/1f0C3kt">39 http://bit.ly/1f0C3kt </a>
    #<a href="http://bit.ly/1mb5UIx">45 http://bit.ly/1mb5UIx<i><b> </b></i></a>
    def removeBitLyLinks( contents )
        contents = getContentsAsNokogiri( contents )
        contents.search('//a[contains(@href,"http://bit.ly")]').each do |node|
            node.remove
        end

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

    def removeLeftoverBadContent( contents )

        removeRegexes = [
            '46 http://bit.ly/1myxEK1',
            '<img src="list-67_1.jpg">40 http://bit.ly/1hEhLL3',
            '49(?:\n*\s*)?<a href="http:\/\/1.usa.gov\/18BOn4u">49 http:\/\/1.usa.gov\/18BOn4u <\/a>'
        ]

        removeRegexes.each do |removeRegex|
            contents = contents.gsub!(/#{removeRegex}/, '')
            if contents == nil
                raise 'Did not find one of the bad content regexes in removeLeftoverBadContent'
            end
        end

        return contents
    end

    def writePrisonerValuesToOutput( output_path )
        CSV.open( output_path, 'wb') do |csv|
            csv << [
                'ID',
                'Name',
                'Type of Prisoner',
                'Date',
                'Type of Date',
                #'Charges',
                'Place of Detention',
                #'Background Description',
                'Picture'
            ]
            printPrisoners = []
            @prisonerTypes.each do |prisonerType|
                prisoners = prisonerType.getPrisoners
                prisoners.each do |prisoner|
                    if printPrisoners.include? prisoner.getId
                        puts prisoner
                    end



                    csv << [
                        prisoner.getId,
                        prisoner.getName,
                        prisonerType.getName,
                        prisoner.getDate,
                        prisoner.getDateType,
                        #prisoner.getCharges,
                        prisoner.getPlaceOfDetention,
                        #prisoner.getBackground
                    ]
                end
            end
        end
    end
end