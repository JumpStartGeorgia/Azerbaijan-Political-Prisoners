def removeAllTags(value)
    return value.gsub(/<(.|\n)*?>/, '')
end

def cleanValue(value)
    value = removeAllTags(value)
    value = value.strip()

    return value
end

def cleanName(name)
    ## Remove numbers
    name = name.gsub(/#{@id}\./, '')

    name = cleanValue ( name )

    return name
end

def cleanDate( date, prisId )
    date = date.to_s

    ## Remove incomplete tag and page number in prisoner ID 36
    date = date.gsub(/<a(.*)47/m, '')

    date = cleanValue( date )

    removePatterns = ['Pretrial detention decision was made on ', 'pretrial detention decision was made on ', '.', ',']
    removePatterns.each do |pattern|
        date = date.gsub(pattern, '')
    end

    #Specific case for prisoner 22: Correct day number, which is incorrectly listed twice
    if prisId == 22
        date = date.gsub('August 2', 'August')
    end

    month = false
    day = false
    year = false

    puts 'date: ' + date

    #Convert days formatted with letters attached to just numbers, i.e. 23rd -> 23; 14th -> 14; 1st -> 1
    date_scan = date.scan(/[0-9]+[a-z]+/)
    if date_scan.length > 0
        replaceString = date_scan[0].gsub(/[a-z]/, '')
        #puts 'Before: ' + date
        #puts 'Part to replace: ' + date_scan[0]
        #puts 'Replace string: ' + replaceString
        date = date.gsub(/[0-9]+[a-z]+/, replaceString)
        #puts 'After: ' + date
    end

    date = date.gsub('March13', 'March 13')


    dateParts = date.split()
    dateParts.each do |part|
        allLetters = part.scan(/^[a-zA-Z]+$/)
        if allLetters.length == 1
            month = allLetters[0]
        end

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


    if (!month)
        raise 'Did not find month for prisoner ' + prisId.to_s
    elsif (!day)
        raise 'Did not find day for prisoner ' + prisId.to_s
    elsif(!year)
        raise 'Did not find year for prisoner ' + prisId.to_s
    end

    date = month + '/' + day + '/' + year

    return date
end

def cleanCharges ( charges )
    charges = cleanValue( charges )
    charges = charges.gsub(/\n/, '')
    charges = charges.squeeze(' ')

    return charges
end

def cleanPlaceOfDetention ( placeOfDetention )
    placeOfDetention = cleanValue( placeOfDetention )

    return placeOfDetention
end

def cleanBackground( background )
    background = background.strip()

    return background
end

