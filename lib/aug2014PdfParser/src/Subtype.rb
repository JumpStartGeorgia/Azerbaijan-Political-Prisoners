class PrisonerSubtype
  def initialize(id, wholeText, letter, prisonerType)
    @id = id
    @prisonerType = prisonerType
    wholeText = wrapPrisoners(wholeText)
    wholeText = wrapName(wholeText, letter)
    @wholeText = wrapDescription(wholeText)

    @name = findName
    @description = findDescription
  end

  def getId
    @id
  end

  def getName
    @name
  end

  def getPrisonerType
    @prisonerType
  end

  def getDescription
    @description
  end

  def findName
    @name = getWholeTextAsNokogiri.css('.subtypeName')[0].content.to_s
  end

  def findDescription
    description = getWholeTextAsNokogiri.css('.subtypeDescription')[0].content.to_s
    description = description.strip

    description = 'No Subtype Description' if description == ''
    @description = description
  end

  def getPrisoners
    @prisoners
  end

  def to_s
    puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
    puts ''
    puts 'Prisoner Subtype Name: ' + @name
    puts ''
    puts 'Prisoner Subtype Description: ' + @description
    puts ''
    puts 'Whole Text: ' + @wholeText
    puts ''
    puts '_________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
  end

  def getWholeTextAsNokogiri
    nokogiri_text = Nokogiri::HTML(@wholeText)
    nokogiri_text.encoding = 'utf-8'
    nokogiri_text
  end

  def findPrisoners
    wholeText = getWholeTextAsNokogiri

    prisoners = []
    (1..98).each do |j|
      prisonerText = wholeText.css('#prisoner-' + j.to_s).to_s
      if prisonerText.length != 0

        prisoner = List_Prisoner.new(j, self, self, prisonerText)
        prisoners.push(prisoner)
      end
    end

    @prisoners = prisoners
  end

  def wrapPrisoners(wholeText)
    firstPrisoner = true

    (1..98).each do |prisNum|
      unless wholeText.scan(/<b>\s*#{prisNum}\./).empty?
        if firstPrisoner
          wholeText = wholeText.gsub(/<b>\s*#{prisNum}\./, '<div id="prisoner-' + prisNum.to_s + '"> \\0')
          firstPrisoner = false
        else
          wholeText = wholeText.gsub(/<b>\s*#{prisNum}\./, '</div><div id="prisoner-' + prisNum.to_s + '"> \\0')
        end
      end
    end

    wholeText
  end

  def wrapName(wholeText, letter)
    # Human Rights Defenders Section b has no bold tag, so special case must be included in order to find it
    if @prisonerType.getName == 'Human Rights Defenders' && letter == 'b'
      wholeText = wholeText.gsub(/b.  (Other cases)/, '<span class="subtypeName">\\1</span>')
    # Religious Activists Section b has a bold tag in the name, so special case must be included in order not to cut off the end of the name
    elsif @prisonerType.getName == 'Religious Activists' && letter == 'e'
      wholeText = wholeText.gsub(/<b>e.  (Cases of those detained in connection with the “Freedom for hijab” protest held on <\/b>\n<i><b>5 October 2012)/, '<span class="subtypeName">\\1</span>')
    else
      wholeText = wholeText.gsub(/<b>\s*#{letter}\.(.*?)<\/b>/, '<span class="subtypeName">\\1</span>')
    end

    wholeText
  end

  def wrapDescription(wholeText)
    wholeText = wholeText.gsub(/<span class="subtypeName">(.*?)<\/span>/m, '\\0<span class="subtypeDescription">')
    wholeText = wholeText.sub(/<div id="prisoner-/, '</span>\\0')

    wholeText
  end
end
