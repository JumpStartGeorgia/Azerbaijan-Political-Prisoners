def removeAllTags(value)
    return value.gsub(/<(.|\n)*?>/, '')
end

def cleanName(name)
    name = name.to_s

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
    charges = charges.to_s

    charges = removeAllTags(charges)
    charges = charges.strip()

    return charges
end

