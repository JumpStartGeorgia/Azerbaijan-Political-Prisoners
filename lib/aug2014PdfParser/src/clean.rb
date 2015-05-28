def removeAllTags(value)
  value.gsub(/<(.|\n)*?>/, '')
end

def cleanValue(value)
  value = removeAllTags(value)
  value = value.strip

  value
end

def cleanName(name)
  ## Remove numbers
  name = name.gsub(/#{@id}\./, '')

  name = cleanValue ( name)

  name
end

def convertMonthToNum(month)
  monthNameNumPairs = [
    %w(January 1),
    %w(February 2),
    %w(March 3),
    %w(April 4),
    %w(May 5),
    %w(June 6),
    %w(July 7),
    %w(August 8),
    %w(September 9),
    %w(October 10),
    %w(November 11),
    %w(December 12)
  ]

  monthNameNumPairs.each do |monthPair|
    return monthPair[1] if month == monthPair[0]
  end

  fail 'Failed month conversion from name to number'
end

def formatDate(date, prisId)
  month = false
  day = false
  year = false

  dateParts = date.split
  dateParts.each do |part|
    allLetters = part.scan(/^[a-zA-Z]+$/)
    month = allLetters[0] if allLetters.length == 1

    allNumbers = part.scan(/^[0-9]+$/)
    if allNumbers.length == 1
      numberString = allNumbers[0]
      if numberString.length == 4
        year = numberString
      else
        day = numberString
      end
    end
  end

  if !month
    fail 'Did not find month for prisoner ' + prisId.to_s
  elsif !day
    fail 'Did not find day for prisoner ' + prisId.to_s
  elsif !year
    fail 'Did not find year for prisoner ' + prisId.to_s
  end

  month = convertMonthToNum(month)

  date = day + '/' + month + '/' + year
  date
end

def cleanDate(date, prisId)
  date = date.to_s

  ## Remove incomplete tag and page number in prisoner ID 36
  date = date.gsub(/<a(.*)47/m, '')

  date = cleanValue(date)

  removePatterns = ['Pretrial detention decision was made on ', 'pretrial detention decision was made on ', '.', ',']
  removePatterns.each do |pattern|
    date = date.gsub(pattern, '')
  end

  # Specific case for prisoner 22: Correct day number, which is incorrectly listed twice
  date = date.gsub('August 2', 'August') if prisId == 22

  # Specific case: March13 -> March 13
  date = date.gsub('March13', 'March 13')

  # Convert days formatted with letters attached to just numbers, i.e. 23rd -> 23; 14th -> 14; 1st -> 1
  date_scan = date.scan(/[0-9]+[a-z]+/)
  if date_scan.length > 0
    replaceString = date_scan[0].gsub(/[a-z]/, '')
    date = date.gsub(/[0-9]+[a-z]+/, replaceString)
  end

  date
end

def cleanCharges(charges)
  charges = cleanValue(charges)
  charges = charges.gsub(/\n/, '')
  charges = charges.squeeze(' ')

  charges
end

def capitalizePlaceOfDetention(placeOfDetention)
  noCapitalize = %w(of the)
  placeOfDetention.split.each do |word|
    word = word.scan(/\w*/)[0].to_s
    unless noCapitalize.include? word
      wordReplacement = word.capitalize
      placeOfDetention = placeOfDetention.gsub(word, wordReplacement)
    end
  end

  placeOfDetention
end

def combineDifferentValuesForSamePrisons(placeOfDetention)
  kurdakhaniPrison = 'Kurdakhani Pre-trial Detention Center (Baku Investigative Prison No. 1)'
  placeOfDetention = placeOfDetention.gsub('Baku Investigative Prison No. 1 (Kurdakhani Pre-trial Detention Center)', kurdakhaniPrison)
  placeOfDetention = placeOfDetention.gsub('Baku Investigative Prison (Kurdakhani Pre-trial Detention Center)', kurdakhaniPrison)
  placeOfDetention = placeOfDetention.gsub('Baku Investigative Prison (Kurdakhani Detention Center)', kurdakhaniPrison)
  placeOfDetention = placeOfDetention.gsub('Baku Investigative Prison (Kurdakhani Prison)', kurdakhaniPrison)
  placeOfDetention = placeOfDetention.gsub('Baku Detention Facility (Kurdakhani Prison)', kurdakhaniPrison)
  placeOfDetention = placeOfDetention.gsub('Baku Detention Facility', kurdakhaniPrison)
  placeOfDetention = placeOfDetention.gsub('Baku Investigative Facility (Kurdakhani Prison)', kurdakhaniPrison)

  shuvalanPrison = 'Shuvalan Pre-trial Detention Center (Investigative Prison No. 3)'
  placeOfDetention = placeOfDetention.gsub('Investigative Prison No. 3 (Shuvalan Pre-trial Detention Center)', shuvalanPrison)
  placeOfDetention = placeOfDetention.gsub('Investigative Prison No. 3 (Shuvelan Prison)', shuvalanPrison)

  placeOfDetention = placeOfDetention.gsub('Sheki Penitentiary Institution', 'Sheki Penitentiary')
  placeOfDetention = placeOfDetention.gsub('Penitentiary Institution No. 14', 'Prison No. 14')
  placeOfDetention = placeOfDetention.gsub('Gobustan Prison', 'Gobustan Closed Prison')

  placeOfDetention
end

def cleanPlaceOfDetention(placeOfDetention, _prisId)
  placeOfDetention = cleanValue(placeOfDetention)
  placeOfDetention = placeOfDetention.gsub(/\n/, '')
  placeOfDetention = placeOfDetention.squeeze(' ')

  placeOfDetention = placeOfDetention.gsub('№', 'No.')
  placeOfDetention = placeOfDetention.gsub('#', 'No.')
  placeOfDetention.scan(/No.[0-9]/).each do |scanned|
    replacementPattern = scanned.gsub(/[0-9]/, ' \\0')
    placeOfDetention = placeOfDetention.gsub(/No.[0-9]/, replacementPattern)
  end

  # Fixed Prisoner 98 typo: "Baki" --> "Baku"
  placeOfDetention = placeOfDetention.gsub(/Baki/, 'Baku')

  placeOfDetention = capitalizePlaceOfDetention(placeOfDetention)
  placeOfDetention = combineDifferentValuesForSamePrisons(placeOfDetention)
  placeOfDetention
end

def cleanBackground(background, _id)
  background = background.gsub(/<span class="background">(.*)<\/span>/m, '\1')
  background = background.strip
  background = background.gsub(/(\s+\n+)/, "\n\n")

  # Delete extra line breaks in Prisoner 3 background
  sentenceRegex = 'He is an expert on the legal and human rights.*?organization\.'
  background.scan(/#{sentenceRegex}/m).each do |scan|
    replacement = scan.gsub(/\n/, "\s")
    background = background.gsub(/#{sentenceRegex}/m, replacement)
  end

  background = background.squeeze(' ')
  background = background.gsub(/<i>\s*\n*<\/i>/, '')
  background = background.gsub(/<b>\s*\n*<\/b>/, '')
  background = background.gsub(/<i>\s*\n*<\/i>/, '')

  background
end
