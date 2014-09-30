class List
    def initialize(input_path)
        contents = openList(input_path)
        contents = removePageRelatedTags( contents )
        contents = removeUnnecessaryTags( contents )
        contents = wrapPrisonerTypes( contents )

        @contents = contents
    end

    def getContents
        return @contents
    end

    def openList( input_path )
        file = File.open(input_path, "rb")
        list = file.read
        file.close

        return list;
    end

    def removePageRelatedTags( list )
        (1..92).each do |i|
            pageRegex = '<a name=' + i.to_s + '><\/a>(?:' + i.to_s + ')?'

            list = list.gsub!(/#{pageRegex}/, '')

            if (!list)
                raise 'Did not find tags related to page #' + i.to_s + ' to remove from list. Regex search: ' + pageRegex
            end
        end

        return list
    end

    def removeUnnecessaryTags( list )
        list = Nokogiri::HTML( list )
        list.encoding = 'utf-8'

        list.xpath('//br').remove()
        list.xpath('//hr').remove()

        list = list.to_s
        return list
    end

    def wrapPrisonerTypes( list )
        ('A'..'G').each do |letter|
            if letter == 'A'
                list = list.gsub( /<b>#{letter}\./, '<div id="' + letter + '-prisoner-type"> \\0' )
            elsif letter == 'G'
                list = list.gsub( /<b>#{letter}\./, '</div><div id="' + letter + '-prisoner-type"> \\0' )
                list = list.gsub( /<\/body>/, '</div></body>')
            else
                list = list.gsub( /<b>#{letter}\./, '</div><div id="' + letter + '-prisoner-type"> \\0' )
            end
        end

        return list
    end
end