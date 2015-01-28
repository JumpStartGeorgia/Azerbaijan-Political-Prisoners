module ChargesHelper
    def displayCharges(charges)
        chargesString = ''

        charges.each do |charge|
            chargesString = chargesString + (link_to charge.article.number, charge) + ' '
        end

        return chargesString.html_safe
    end

  def linkToIncident(charge)
    return link_to charge.incident.prisoner.name + ' ' + charge.incident.date_of_arrest.to_s, prisoner_path(charge.incident.prisoner, anchor: 'incident-' + charge.incident.date_of_arrest.to_s)
  end
end
