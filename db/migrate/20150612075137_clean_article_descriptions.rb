class CleanArticleDescriptions < ActiveRecord::Migration
  def up
    Article.transaction do
      puts ''
      puts ''
      puts ''
      puts ''
      Article.all.each do |art|
        if art.description.present?
          regex = /<[\/]?span.*?>|&nbsp;/
          unclean_strs = art.description.scan(regex)
          puts '----------------------------------------------------------------'
          puts 'Article #' + art.number
          puts ''
          puts art.description
          puts ''
          if unclean_strs.present?
            corrected_desc = art.description
            unclean_strs.each_with_index do |unclean_str, index|
              puts (index + 1).to_s + '. ' + unclean_str
              if unclean_str == '&nbsp;'
                corrected_desc = corrected_desc.sub(unclean_str, ' ')
              else
                corrected_desc = corrected_desc.sub(unclean_str, '')
              end
            end
            art.description = corrected_desc

            puts ''
            puts 'Corrected: ' + art.description
            puts ''

            art.save
          end
          puts ''
        end
      end
      puts ''
      puts ''
      puts ''
      puts ''
    end
  end

  def down
  end
end
