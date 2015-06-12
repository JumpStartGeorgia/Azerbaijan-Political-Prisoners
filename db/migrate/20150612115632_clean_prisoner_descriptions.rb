class CleanPrisonerDescriptions < ActiveRecord::Migration
  def up
    Incident.transaction do
      # Gets all prisoners that have at least one incident with a
      # description_of_arrest and/or description_of_release
      Prisoner.all.select { |pris| pris.incidents.select { |inc| inc.description_of_arrest.present? || inc.description_of_release.present? }.present? }.each do |pris|
        puts '----------------------------------------------------------------------------------------------------------------------'
        puts 'Prisoner: ' + pris.name
        puts ''

        pris.incidents.each do |inc|
          if inc.description_of_arrest.present?
            unclean_strs = inc.description_of_arrest.scan(/<div.*?>|<\/div>|<p.*?>|<br.*?>|<span.*?>|<\/span>|&nbsp;|&ldquo;|&rdquo;|&lsquo;|&rsquo;/).select { |unclean_str| unclean_str != '<p>' }
            if unclean_strs.present?
              puts 'Description of arrest: ' + inc.description_of_arrest
              puts ''

              unclean_strs.each_with_index do |unclean_str, index|
                if unclean_str == '&nbsp;'
                  inc.description_of_arrest = inc.description_of_arrest.sub(unclean_str, ' ')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> \' \''
                elsif unclean_str.match(/<p.*?>/).present?
                  inc.description_of_arrest = inc.description_of_arrest.sub(unclean_str, '<p>')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> <p>'
                elsif unclean_str.match(/&ldquo;|&rdquo;/)
                  inc.description_of_arrest = inc.description_of_arrest.sub(unclean_str, '"')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> "'
                elsif unclean_str.match(/&lsquo;|&rsquo;/)
                  inc.description_of_arrest = inc.description_of_arrest.sub(unclean_str, "'")
                  puts (index + 1).to_s + '. ' + unclean_str + " >>> '"
                else
                  inc.description_of_arrest = inc.description_of_arrest.sub(unclean_str, '')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> REMOVED'
                end
              end

              inc.description_of_arrest = inc.description_of_arrest.gsub(/<p> <\/p>/, '')

              puts ''
              puts 'New description of arrest: ' + inc.description_of_arrest
              puts ''
            end
          end

          if inc.description_of_release.present?
            unclean_strs = inc.description_of_release.scan(/<div.*?>|<\/div>|<p.*?>|<br.*?>|<span.*?>|<\/span>|&nbsp;|&ldquo;|&rdquo;|&lsquo;|&rsquo;/).select { |unclean_str| unclean_str != '<p>' }
            if unclean_strs.present?
              puts ''
              puts ''
              puts ''
              puts 'Description of release: ' + inc.description_of_release
              puts ''

              unclean_strs.each_with_index do |unclean_str, index|
                if unclean_str == '&nbsp;'
                  inc.description_of_release = inc.description_of_release.sub(unclean_str, ' ')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> \' \''
                elsif unclean_str.match(/<p.*?>/).present?
                  inc.description_of_release = inc.description_of_release.sub(unclean_str, '<p>')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> <p>'
                elsif unclean_str.match(/&ldquo;|&rdquo;/)
                  inc.description_of_release = inc.description_of_release.sub(unclean_str, '"')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> "'
                elsif unclean_str.match(/&lsquo;|&rsquo;/)
                  inc.description_of_release = inc.description_of_release.sub(unclean_str, "'")
                  puts (index + 1).to_s + '. ' + unclean_str + " >>> '"
                else
                  inc.description_of_release = inc.description_of_release.sub(unclean_str, '')
                  puts (index + 1).to_s + '. ' + unclean_str + ' >>> REMOVED'
                end
              end

              inc.description_of_release = inc.description_of_release.gsub(/<p> <\/p>/, '')

              puts ''
              puts 'New description of release: ' + inc.description_of_release
              puts ''
            end
          end
        end

        pris.save
      end
    end
  end

  def down
  end
end
