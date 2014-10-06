
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
        file = File.open(input_path, "rb", encoding: 'UTF-8')
        list = file.read
        file.close
        return list
    end

    def prepareContents(contents)
        contents = removeFootnoteNumbers( contents )
        contents = removeSingleTagElements( contents )
        contents = removePageRelatedTags( contents )
        contents = removeBitLyLinks( contents )
        contents = removeLeftoverBadContent( contents )
        contents = wrapPrisonerTypes( contents )
        return contents
    end

    def replaceSpecificPatternInString( string, pattern, replacementPattern )

        string = string.gsub!(pattern, replacementPattern )
        if string == nil
            raise 'Pattern not removed from list: ' + removeRegex
        end

        return string
    end

    def removeFootnoteNumbers( contents )
        footnotePatternsOneDigit = [
            'issue  of <br/>political prisoners in Azerbaijan.”1',
            'according to the criteria set <br/>out in PACE Resolution No. 1900, from 3 October 2012.2',
            'Alibayli is recognized as prisoner of <br/>conscience  by  Amnesty  international.3',
            'Journalists  has <br/>expressed its concern over his arrest.4',
            'International described the charges against the journalist as questionable.5',
            'illegally carried and stored these arms and ammunition.”6',
            'Hashimli has been recognized by Amnesty International as a prisoner of conscience7',
            'Mammadov has been recognized by Amnesty International as a prisoner of conscience.8',
            'mentioned  in  the <br/>statement  of  the  OSCE  media  freedom  representative9'
        ]
        footnotePatternsTwoDigits = [
            'in  the  report  of  the  Council  of <br/>Europe Commissioner for Human Rights10',
            '  Mammadov <br/>was  also  a  blogger11',
            'and a search was carried out at her home and <br/>office.12',
            '<br/>social  media  networks,  particularly  on  Facebook 13',
            'as  a  prisoner  of  conscience  by  Amnesty <br/>International.14',
            'brought <br/>against the journalist is not convincing.15',
            'European Court of <br/>Human Rights regarding Yagublu’s arrest.16',
            'stated that the Azerbaijani people were owed an apology17',
            'a parliamentarian. Based <br/>on  this  video18',
            'three  years  in <br/>jail. After her arrest, Ahmadova told the media19',
            'the  charges <br/>brought against Zeynalli as spurious.20',
            'Cooperation <br/>Public Union (VICPU),  publicized a preliminary opinion21',
            'International recognized him as a prisoner of <br/>conscience.22',
            'arrest  and  underscored  the <br/>necessity of his release.23',
            'head  of  Chalkhan  LLC,  and  as  an  independent  attorney.24',
            'and <br/>social media, creating a major buzz.25',
            'Vidadi Mammadov, Reporter for <i>Azadliq</i>. 26',
            'achieve <br/>democratic  change through peaceful means.27',
            'wrists. He passed away several days later in the hospital.28',
            'declared by Amnesty International as prisoners <br/>of conscience.29',
            'member  of  the  German <br/>Marshall Fund and Revenue Watch.30',
            'arrest  as  a  “politically  motivated <br/>prosecution,”31',
            'and  recognizes  him  as  a  prisoner  of  conscience.32',
            'underscored the <br/>necessity  of  Mammadov’s  release  in  a  report. 33',
            'appraise from high-level US officials for eliminating <br/>Dadashbeyli’s group.34',
            'President  Aliyev  for  the  social  situation  in  the <br/>country.35',
            'Bagirov posted the video <br/>of his  speech onto  YouTube36',
            'covered in the U.S. State Department’s Human Rights Report for 201337',
            '( The statement still remains on the Ministry’s website).38',
            'from  the  investigation  in  1995  with  no  reason  given. 39',
            'and  were  considered  to  be  political  prisoners.40',
            'Kazimov, along with  the other political <br/>prisoners.41',
            'concluded that Poladov was also a political prisoner.42',
            'prisoners  by  independent  experts.43',
            '<br/>remained in prison, and expressed concern over this.44',
            'the local  executive institutions for their involvement.4542',
            'He criticized the local  executive institutions for their involvement.45',
            'the  ECHR  recognized  the  violation  of  both  rights. 46',
            '2007 called for a fair trial for Ali Insanov.47',
            'The ECtHR ruled that <br/>his right to a fair trial was violated.48',
            'as an <br/>example of pressure on the families of opposition figures.49'
        ]

        footnotePatternsOneDigit.each do |pattern|
            contents = replaceSpecificPatternInString(contents, pattern, pattern[0, pattern.length - 1])
        end

        footnotePatternsTwoDigits.each do |pattern|
            contents = replaceSpecificPatternInString(contents, pattern, pattern[0, pattern.length - 2])
        end

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
            '<a href="http://1.usa.gov/18BOn4u">49 http://1.usa.gov/18BOn4u </a>',
            '34 https://search.wikileaks.org/plusd/cables/08BAKU383_a.html',
            '37 http://1.usa.gov/18BOn4u',
            '<a href="http://1.usa.gov/18BOn4u"> </a>'
        ]

        removeRegexes.each do |removeRegex|
            contents = replaceSpecificPatternInString(contents, removeRegex, '')
        end

        puts contents

        return contents
    end

    def printPrisoner( prisoner )
        prisonerIdsToPrint = []

        if prisonerIdsToPrint.include? prisoner.getId
            puts prisoner
        end

        #If a prisoner text contains the pattern http:// and is not approved, prints it out
        scanString = 'http://'
        numberHttpStrings = prisoner.getWholeText.scan(/#{scanString}/).length
        approvedHttpPrisoners = [83]

        if numberHttpStrings > 0
            if !approvedHttpPrisoners.include? prisoner.getId
                puts prisoner
                puts 'Prisoner #' + prisoner.getId.to_s + ' has ' + numberHttpStrings.to_s + ' http:// patterns'
            end
        end
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
            @prisonerTypes.each do |prisonerType|
                prisoners = prisonerType.getPrisoners
                prisoners.each do |prisoner|
                    #printPrisoner( prisoner )

                    csv << [
                        prisoner.getId,
                        prisoner.getName,
                        prisonerType.getName,
                        prisoner.getDate,
                        prisoner.getDateType,
                        prisoner.getCharges,
                        prisoner.getPlaceOfDetention,
                        #prisoner.getBackground
                    ]
                end
            end
        end
    end
end