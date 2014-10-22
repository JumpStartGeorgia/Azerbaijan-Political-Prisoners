
require_relative 'Type.rb'


class List
    def initialize(input_path)
        contents = openListFromPath(input_path)
        @input_path, @contents = input_path, prepareContents(contents)
    end

    def getPrisonerTypes
        return @prisonerTypes
    end

    def getPrisoners
        prisoners = []

        @prisonerTypes.each do |prisonerType|
            prisonerType.getPrisoners.each do |prisoner|
                prisoners.push(prisoner)
            end
        end

        return prisoners
    end

    def findPrisonerTypes
        contents = getContentsAsNokogiri( @contents )
        subtypeIdIterator = 1

        prisonerTypes = []
        ('A'..'G').each do |letter|
            prisonerType = PrisonerType.new( contents.css( '#' + letter + '-prisoner-type' ).to_s, letter, subtypeIdIterator )
            prisonerTypes.push( prisonerType )
            subtypeIdIterator += prisonerType.getSubtypes.length
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
        contents = removeFootnotes( contents )
        contents = removePageRelatedTags( contents )
        contents = removeSingleTagElements( contents )
        contents = wrapPrisonerTypes( contents )
        return contents
    end

    def replaceSpecificPatternInString( string, pattern, replacementPattern )
        string = string.gsub!(pattern, replacementPattern )
        if string == nil
            raise 'Pattern not removed from list: ' + pattern
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

    # Removes the footnotes at the bottom of the page
    # Strategy: Tries using three general regex to match the footnote, and includes specific cases for the exceptions that don't match these cases
    ### Examples of removed footnotes:
    #<br/>1<a href="http://bit.ly/P8Z2Qy"> http://bit.ly/P8Z2Qy </a> <br/>2<a href="http://bit.ly/1piq992"> http://bit.ly/1piq992  </a><br/>
    #<br/>12 Additional information has been replaced about Leyla Yunus’s arrest in the report. <br/>
    #<br/><a href="https://www.facebook.com/HAQQINqulu777">13 https://www.facebook.com/HAQQINqulu777 <br/></a><a href="http://bit.ly/1jYMJQI">14 http://bit.ly/1jYMJQI <br/></a> <br/>
    def removeFootnotes( contents )
        (1..49).each do |footnoteNum|
            footnoteRemoved = false
            footnoteNumString = footnoteNum.to_s
            patterns = [
                #Specific cases
                '<br/>' + footnoteNumString + ' Additional information has been replaced about Leyla Yunus’s arrest in the report. <br/>',
                '<br/>' + footnoteNumString + 'http://www.epde.org/tl_files/EPDE/EPDE%20PRESS%20RELEASES/EMDS_ICV_2%20Interim%20Rep_2013_AZ.pdf <br/>',
                '</a>' + footnoteNumString + ' http://www.bbc.co.uk/azeri/azerbaijan/2014/06/140630_aliabbas_rustamov_arrest.shtml <br/>',
                '<br/><img src="list-67_1.jpg">' + footnoteNumString + ' http://bit.ly/1hEhLL3 <br/></a>',
                #General cases
                '<a href="http.*?">' + footnoteNumString + ' .*?</a>',
                footnoteNumString + '<a href="http.*?">.*?</a>',
                '<br/>' + footnoteNumString + ' .*?<br/>'
            ]

            patterns.each do |pattern|
                scan = contents.scan(/#{pattern}/)
                if scan.length == 1
                    contents = contents.gsub(/#{pattern}/, '')
                    footnoteRemoved = true
                    break
                end
            end

            if (!footnoteRemoved)
                raise 'Footnote #' + footnoteNumString + ' not found and not removed'
            end
        end
        return contents
    end

    def checkNoImgTags(contents)
        scan = contents.scan(/<img src="list-\d+_\d+.jpg"(?:\/)?>/)
        if scan.length > 0
            puts scan
            raise 'Forbidden image tags found'
        end

        return contents
    end

    # Removes tags related to the page breaks in the PDF, such as:
    #<a name=1></a> <br/><b> </b><br/>
    #<a name=2></a>2 <br/>(NEW LINE)<br/>
    # <a name=66></a>66 <br/>(NEW LINE)<br/>
    # <a name=67></a><img src="list-67_1.jpg"/><br/>(NEW LINE)67 <br/>(NEW LINE)<br/>
    #<a name=70></a><img src="list-70_1.jpg"/><br/>(NEW LINE)<img src="list-70_2.jpg"/><br/>(NEW LINE)70 <br/>(NEW LINE)<br/>
    def removePageRelatedTags( contents )
        regex = '(?:<br\/>\n)?(?:<hr\/>\n)?<a name=\d+><\/a>(<img src="list-\d+_\d+.jpg"\/?><br\/>\n)*\d*(?:\s<br\/>\n\s<br\/>)?\n*'
        scan = contents.scan(/#{regex}/m)

        if scan.length == 92
            contents = contents.gsub(/#{regex}/m, '')
        else
            raise 'Did not find 92 page tags'
        end
        checkNoImgTags(contents)

        return contents
    end

    def removeSingleTagElements( contents )
        contents = contents.gsub(/<br\/>\s<br\/>/, "\n\n")
        contents = getContentsAsNokogiri( contents )

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

    def printPrisoner( prisoner )
        prisonerIdsToPrint = []

        if prisonerIdsToPrint.include? prisoner.getId
            puts prisoner
        end
    end

    def outputPrisoners( output_path )
        CSV.open( output_path, 'wb') do |csv|
            csv << [
                'ID',
                'Name',
                'Type of Prisoner',
                'Subtype ID',
                'Date',
                'Type of Date',
                #'Charges',
                'Place of Detention',
                'Background Description',
                #'Picture'
            ]
            @prisonerTypes.each do |prisonerType|
                prisonerType.getPrisoners.each do |prisoner|
                    printPrisoner( prisoner )

                    csv << [
                        prisoner.getId,
                        prisoner.getName,
                        prisonerType.getName,
                        prisoner.getPrisonerSubtypeId,
                        prisoner.getDate,
                        prisoner.getDateType,
                        #prisoner.getCharges,
                        prisoner.getPlaceOfDetention,
                        prisoner.getBackground
                    ]
                end
            end
        end
    end

    def outputSubtypes( output_path )
        CSV.open( output_path, 'wb' ) do |csv|
            csv << [
                'ID',
                'Name',
                'Parent Type',
                'Description'
            ]
            @prisonerTypes.each do |prisonerType|
                prisonerType.getSubtypes.each do |subtype|
                    csv << [
                        subtype.getId,
                        subtype.getName,
                        subtype.getPrisonerType.getName,
                        subtype.getDescription
                    ]
                end
            end
        end
    end

    def outputPlacesOfDetention( output_path )
        CSV.open( output_path, 'wb' ) do |csv|
            csv << [
                'Place of Detention'
            ]
            uniquePrisons = []

            getPrisoners().each do |prisoner|
                placeOfDetention = prisoner.getPlaceOfDetention
                if placeOfDetention != 'Not Listed'
                    if !uniquePrisons.include? placeOfDetention
                        uniquePrisons.push(placeOfDetention)
                    end
                end
            end

            uniquePrisons =  uniquePrisons.sort_by{|word| word}

            uniquePrisons.each do |prison|
                csv << [
                    prison
                ]
            end
        end
    end
end