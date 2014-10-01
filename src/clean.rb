def removeAllTags(value)
    return value.gsub(/<(.|\n)*?>/, '')
end

def cleanName(name)
    ## Remove numbers
    name = name.gsub(/#{@id}\./, '')

    name = removeAllTags(name)
    name = name.strip()

    return name
end

def cleanDate( date )
    date = date.to_s

    ## Remove incomplete tag and page number in prisoner ID 36
    date = date.gsub(/<a(.*)47/m, '')

    date = removeAllTags(date)
    date = date.strip()

    return date
end

def cleanCharges ( charges )
    charges = removeAllTags(charges)
    charges = charges.strip()

    return charges
end

def cleanPlaceOfDetention ( placeOfDetention )
    placeOfDetention = removeAllTags(placeOfDetention)
    placeOfDetention = placeOfDetention.strip()

    return placeOfDetention
end

def cleanBackground( background )
    background = background.strip()

    return background
end
