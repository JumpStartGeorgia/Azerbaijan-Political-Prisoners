def cleanName(name)
    name = name.to_s

    ## Remove numbers
    name = name.gsub(/#{@id}\./, '')

    name = name.gsub(/<(.|\n)*?>/, '')
    name = name.strip()

    return name
end

def cleanDate( date )
    date = date.to_s

    ## Remove incomplete tag and page number in prisoner ID 36
    date = date.gsub(/<a(.*)47/m, '')

    date = date.gsub(/<(.|\n)*?>/, '')
    date = date.strip()

    return date
end

def cleanCharges ( charges )
    charges = charges.to_s

    ## Remove all tags
    charges = charges.gsub(/<(.|\n)*?>/, '')
    charges = charges.strip()

    return charges
end