require_relative 'clean.rb'
require_relative 'Article.rb'

class List_Prisoner
  def checkNotListedValue(value, notListedArray, label)
    if value.length == 0
      if notListedArray.include? @id
        value = 'Not Listed'
      else
        fail 'Prisoner ' + @id.to_s + ' has no ' + label + ' (not in approved array of prisoners with no ' + label + ')'
      end
    end

    value
  end

  def initializeData
    wholeText = getWholeTextAsNokogiri

    name = cleanName(wholeText.css('.prisoner-name').to_s)
    fail 'Prisoner ID ' + @id + ' name not found' if name.length == 0

    date = formatDate(cleanDate(wholeText.css('.date-of-arrest'), @id), @id)
    charges = separateCharges(cleanCharges(wholeText.css('.charges').to_s))

    placeOfDetention = cleanPlaceOfDetention(wholeText.css('.place-of-detention').to_s, @id)
    placeOfDetention = checkNotListedValue(placeOfDetention, [27, 78, 79, 80, 81], 'place of detention')

    background = cleanBackground(wholeText.css('.background').to_s, @id)
    background = checkNotListedValue(background, (35..49).to_a.concat((87..89).to_a), 'background')

    [name, date, charges, placeOfDetention, background]
  end

  def initialize(id, prisonerType, prisonerSubtype, wholeText)
    @id = id
    @prisonerType = prisonerType
    @prisonerSubtype = prisonerSubtype
    @wholeText = prepareText(wholeText)
    @name, @date, @charges, @placeOfDetention, @background = initializeData
    approveHttpPattern
  end

  def to_s
    puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
    puts ''
    puts 'ID: ' + @id.to_s
    puts ''
    puts 'Whole Text: ' + @wholeText
    puts ''
    puts 'ID: ' + @id.to_s
    puts ''
    puts 'Name: ' + @name
    puts ''
    puts 'Date: ' + @date
    puts ''
    puts 'Charges: ' + @charges
    if @placeOfDetention
      puts ''
      puts 'Place of Detention: ' + @placeOfDetention
    end
    if @background
      puts ''
      puts 'Background: ' + @background
    end
    puts ''
    puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
  end

  def getId
    @id
  end

  def getPrisonerType
    @prisonerType
  end

  def getPrisonerSubtype
    @prisonerSubtype
  end

  def getPrisonerSubtypeId
    if @prisonerSubtype == 'No Subtype'
      return @prisonerSubtype
    else
      return @prisonerSubtype.getId
    end
  end

  def getPrisonerSubtypeName
    if @prisonerSubtype == 'No Subtype'
      return @prisonerSubtype
    else
      return @prisonerSubtype.getName
    end
  end

  def getPrisonerSubtypeDescription
    if @prisonerSubtype == 'No Subtype'
      return @prisonerSubtype
    else
      return @prisonerSubtype.getDescription
    end
  end

  def getWholeText
    @wholeText
  end

  def setWholeText=(wholeText)
    @wholeText = wholeText
  end

  def getName
    @name
  end

  def getDate
    @date
  end

  def getCharges
    @charges
  end

  def getPlaceOfDetention
    @placeOfDetention
  end

  def getBackground
    @background
  end

  def getWholeTextAsNokogiri
    nokogiri_text = Nokogiri::HTML(@wholeText)
    nokogiri_text.encoding = 'utf-8'
    nokogiri_text
  end

  def wrapBackground(wholeText)
    regexForBackgroundLabel = [
      '(Case\s*)?(b)?(B)?ackground(<\/b>)?:(\s*)?(<\/b>)?',
      '<b>Brief\s*Summary\s*of\s*the\s*Case:(\s*)?(<\/b>)?',
      # For prisoner ID 30
      'Background of person:'
    ]

    regexForBackgroundLabel.each do |regex|
      wholeText = wholeText.gsub(
        /#{regex}/,
        '</span>\\0<span class="background">'
      )
    end

    wholeText += '</span>'

    wholeText
  end

  def wrapValues(wholeText)
    wholeText = wholeText.gsub(
      /<b>\s*#{@id}\./,
      '<span class="prisoner-name">\\0'
    )

    dateArrestRegexPatterns = ['Date of arrest:', 'Date of arrest\s*<\/b>:', 'Detention date:', 'Date of Detention:', 'Date of detention:', 'Date of Detention</b>:']

    dateArrestRegexPatterns.each do |pattern|
      wholeText = wholeText.gsub(
        /#{pattern}/,
        '</span>\\0<span class="date-of-arrest">'
      )
    end

    wholeText = wholeText.gsub(
      /(<b>The\s*)?Charge(:)?(s)?(d)?(<\/b>)?:/,
      '</span>\\0<span class="charges">'
    )

    wholeText = wholeText.gsub(
      /Place(.*)of(.*)[dD].*etention(<\/b>)?:/m,
      '</span>\\0<span class="place-of-detention">'
    )

    wholeText = wrapBackground(wholeText)

    # Remove closing </b> tag after opening span tag
    wholeText = wholeText.gsub(/<span class="charges"><\/b>/, '<span class="charges">')
    wholeText = wholeText.gsub(/<span class="place-of-detention">\s*<\/b>/, '<span class="place-of-detention">')

    wholeText
  end

  # Charges of prisoners 87-89 are formatted differently, using the words 'Article', 'Part' and 'Item'
  def reformatLifetimePrisoners(chargesText, regexArticleNumber)
    if (87..89).to_a.include? @id
      # Remove occurrence of 'Items' so that Articles and Parts only need to be combined
      chargesText = chargesText.gsub(/Article 145, Part 2, Items 1, 2, 5 and 6 .*?personal property\);/, 'Article 145.2.1 (); Article 145.2.2 (); Article 145.2.5 (); Article 145.2.6 ();')

      # Replace this formatting exception with the standard formatting for prisoners 87-89
      chargesText = chargesText.gsub('Part 3 of Article 220-1', 'Article 220-1, Part 3')

      chargesText += ';'
      articleSections = chargesText.scan(/Article #{regexArticleNumber}.*?;/)

      articleSections.each do |articleSection|
        originalSection = articleSection.to_s
        articleNumber = articleSection.scan(/Article (#{regexArticleNumber})/)[0][0].to_s
        articleSection = articleSection.gsub(/Article #{regexArticleNumber}/, '')
        articleSection = articleSection.gsub(/#{regexArticleNumber} \(/, articleNumber + '.\\0')
        articleSection = 'Article ' + articleNumber + articleSection

        chargesText = chargesText.gsub(originalSection, articleSection)
      end
    end

    chargesText
  end

  def editChargesText(chargesText, regexArticleNumber)
    chargesText = chargesText.gsub('Criminal Code (of 1960) ', '')

    # Remove 'of the Criminal Code' when it occurs between a number and an opening parenthesis
    chargesText = chargesText.gsub(/(#{regexArticleNumber}) of the Criminal Code\s?(\()/, '\\1 \\2')

    # Prisoners 35-37 remove extra -ci on the end of article 278
    chargesText = chargesText.gsub('278-ci', '278')

    # Prisoner 40 formatting exception
    chargesText = chargesText.gsub('274(', '274 (')
    chargesText = chargesText.gsub('278(', '278 (')

    # Prisoners 45-49 make Article 28 detectable by parser
    chargesText = chargesText.gsub('28, 214.2', '28 (), 214.2')

    # Prisoners 84-86 make article number detectable by parser
    chargesText = chargesText.gsub('Article 168.2 of the Criminal Code', 'Article 168.2 () of the Criminal Code')

    chargesText = reformatLifetimePrisoners(chargesText, regexArticleNumber)

    chargesText
  end

  def separateCharges(chargesText)
    if (87..89).to_a.include? @id
      criminalCode = '1960'
    else
      criminalCode = 'Current'
    end

    # Matches article numbers, including 167.2.2.1; 313; 28; 220-1
    regexArticleNumber = '(?:[0-9]|[\.\-])*[0-9]'

    chargesText = editChargesText(chargesText, regexArticleNumber)

    separatedCharges = chargesText.scan(/(#{regexArticleNumber}) \(/)

    charges = []
    separatedCharges.each_with_index do |articleNumber|
      articleNumber = articleNumber[0].to_s
      multipleOccurrencesOfSameCharge = false

      # Check for repeat occurrences of article and do not add article if it has already been added
      charges.each do |storedCharge|
        if storedCharge.getNumber == articleNumber
          multipleOccurrencesOfSameCharge = true
        end
      end

      unless multipleOccurrencesOfSameCharge
        charges.push(List_Article.new(criminalCode, articleNumber))
      end
    end

    charges
  end

  def prepareText(wholeText)
    wholeText = wholeText.gsub(/<div id="prisoner-#{@id}">/, '')
    wholeText = wholeText.gsub(/<\/div>/, '')
    wholeText = wrapValues(wholeText)

    wholeText
  end

  def approveHttpPattern
    # If a prisoner text contains the pattern http:// and is not approved, prints it out
    pattern = 'http'
    numberHttpStrings = @wholeText.scan(/#{pattern}/).length
    approvedHttpPrisoners = [3, 4, 5, 6, 83]

    if numberHttpStrings > 0
      unless approvedHttpPrisoners.include? @id
        puts self
        puts 'Prisoner #' + @id.to_s + ' has ' + numberHttpStrings.to_s + ' "' + pattern + '" patterns'
      end
    end
  end
end
