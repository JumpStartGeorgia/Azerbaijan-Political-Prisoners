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

def cleanDate( date )
    date = date.to_s

    ## Remove incomplete tag and page number in prisoner ID 36
    date = date.gsub(/<a(.*)47/m, '')

    date = cleanValue( date )

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
