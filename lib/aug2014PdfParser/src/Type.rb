require_relative 'Prisoner.rb'
require_relative 'Subtype.rb'

class PrisonerType
  def initialize(wholeText, letter, subtypeIdIterator)
    @name = setNameFromLetter(letter)
    wholeText = wrapSubtypes(wholeText)
    @subtypes = findSubtypes(wholeText, subtypeIdIterator)
    @wholeText = wrapPrisoners(wholeText)
  end

  def getWholeText
    @wholeText
  end

  def getName
    @name
  end

  def getPrisoners
    @prisoners
  end

  def getSubtypes
    @subtypes
  end

  def findSubtypes(wholeText, subtypeIdIterator)
    subtypes = []
    prisonerTypeText = getWholeTextAsNokogiri(wholeText)

    ('a'..'g').each do |letter|
      subtypeText = prisonerTypeText.css('#subtype-' + letter).to_s

      if subtypeText.length != 0
        subtype = PrisonerSubtype.new(subtypeIdIterator, subtypeText, letter, self)
        subtypeIdIterator += 1
        subtypes.push(subtype)
      end
    end

    @subtypes = subtypes
  end

  def findPrisoners
    prisoners = []
    prisonerTypeText = getWholeTextAsNokogiri(@wholeText)

    # Find the prisoners contained in subtypes
    @subtypes.each do |subtype|
      subtype.findPrisoners
      prisoners.concat(subtype.getPrisoners)
    end

    # If a prisoner is not in a subtype, then look for it in the whole text of the prisonerType
    (1..98).each do |j|
      prisonerAlreadyFound = false
      prisoners.each do |prisoner|
        prisonerAlreadyFound = true if j == prisoner.getId
      end

      unless prisonerAlreadyFound
        prisonerText = prisonerTypeText.css('#prisoner-' + j.to_s).to_s
        if prisonerText.length != 0
          prisoner = List_Prisoner.new(j, self, 'No Subtype', prisonerText)
          prisoners.push(prisoner)
        end
      end
    end

    @prisoners = prisoners
  end

  def getWholeTextAsNokogiri(wholeText)
    nokogiri_text = Nokogiri::HTML(wholeText)
    nokogiri_text.encoding = 'utf-8'
    nokogiri_text
  end

  def setNameFromLetter(letter)
    if letter == 'A'
      name = 'Journalists and Bloggers'
    elsif letter == 'B'
      name = 'Human Rights Defenders'
    elsif letter == 'C'
      name = 'Youth Activists'
    elsif letter == 'D'
      name = 'Politicians'
    elsif letter == 'E'
      name = 'Religious Activists'
    elsif letter == 'F'
      name = 'Lifetime Prisoners'
    elsif letter == 'G'
      name = 'Other Cases'
    end

    name
  end

  def wrapSubtypes(wholeText)
    hasSubtypes = false

    # Wrap Human Rights Defenders Section 'b.  Other cases' manually (it is not contained in a bold tag)
    if @name == 'Human Rights Defenders'
      wholeText = wholeText.gsub(/b\.  Other cases/, '</div><div id="subtype-b"> \\0')
    end

    ('a'..'g').each do |letter|
      if letter == 'a'
        wholeText = wholeText.gsub(/<b>\s*#{letter}\./, '<div id="subtype-' + letter + '"> \\0')
      else
        wholeText = wholeText.gsub(/<b>\s*#{letter}\./, '</div><div id="subtype-' + letter + '"> \\0')
      end

      if wholeText.include? '<div id="subtype-' + letter + '">'
        hasSubtypes = true
      end
    end

    wholeText += '</div>' if hasSubtypes

    wholeText
  end

  def wrapPrisoners(wholeText)
    if @subtypes.empty?
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

      wholeText += '</div>'
    end

    wholeText
  end
end
