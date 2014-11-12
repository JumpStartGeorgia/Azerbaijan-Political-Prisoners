module ChargesHelper
    def displayCharges(charges)
        chargesString = ''

        charges.each do |charge|
            chargesString = chargesString + (link_to charge.article.number, charge) + ' '
        end

        return chargesString.html_safe
    end
end
