class Prison < ActiveRecord::Base
  include StringOutput

  has_many :incidents, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  translates :name, :description, fallbacks_for_empty_translations: true

  # Allows reference of specific translations, i.e. post.title_az
  # or post.title_en
  globalize_accessors

  # strip extra spaces before saving
  auto_strip_attributes :name, :description

  # permalink
  extend FriendlyId
  friendly_id :name_en, use: :history

  def should_generate_new_friendly_id?
    # Always try to generate new slug (will use current slug if name_en has
    # not changed)
    true
  end

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << [
        I18n.t('activerecord.attributes.prison.name'),
        I18n.t('activerecord.attributes.prison.description')
      ]
      all.each do |prison|
        csv << [prison.name, remove_tags(prison.description)]
      end
    end
  end

  def self.generate_prison_prisoner_count_chart_json
    dir_path = Rails.public_path.join('generated', 'json', I18n.locale.to_s)
    json_path = dir_path.join('prison_prisoner_count_chart.json')
    # if folder path not exist, create it
    FileUtils.mkpath(dir_path) unless File.exist?(dir_path)
    File.open(json_path, 'w') do |f|
      f.write(current_prisoner_counts.to_json)
    end
  end

  # include the current prisoner count with the prisons
  def self.with_current_and_all_prisoner_count(prison_id = nil)
    # this old query counts number of incidents, not people
    # sql = 'select p.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count from prisons as p left join (select prison_id, count(*) as count from incidents group by prison_id) as i_all on i_all.prison_id = p.id left join (select prison_id, count(*) as count from incidents where date_of_release is null group by prison_id) as i_current on i_current.prison_id = p.id'
    sql = 'select p.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count  from prisons as p  left join (select x.prison_id, count(*) as count from  (select prison_id from incidents group by prison_id,prisoner_id) as x group by x.prison_id) as i_all on i_all.prison_id = p.id  left join (select prison_id, count(*) as count from incidents where date_of_release is null group by prison_id) as i_current on i_current.prison_id = p.id'
    sql << ' where p.id = ?' if prison_id.present?
    find_by_sql([sql, prison_id])
  end

  private

  def self.current_prisoner_counts_data
    prisons = []

    current_prisoner_counts_sql(10).each do |prison|
      prisons.append(y: prison[:prisoner_count],
                     name: prison[:prison_name],
                     link: "/#{I18n.locale}/prisons/#{prison[:slug]}",
                     summary: summary(prison))
    end

    prisons
  end

  def self.summary(prison)
    I18n.t('prison.current_prisoner_count_chart.summary',
           number_prisoners: "<strong>#{prison[:prisoner_count]}</strong>",
           prison_name: "<strong>#{prison[:prison_name]}</strong>",
           count: prison[:prisoner_count]
          )
  end

  def self.current_prisoner_counts_text
    {
      explore_prisons: I18n.t('prison.current_prisoner_count_chart.static_text.explore_prisons'),
      title: I18n.t('prison.current_prisoner_count_chart.static_text.title'),
      number_prisoners: I18n.t('prison.current_prisoner_count_chart.static_text.number_prisoners'),
      prisons_path: Rails.application.routes.url_helpers
        .prisons_path(locale: I18n.locale),
      highcharts: I18n.t('highcharts')
    }
  end

  def self.current_prisoner_counts
    {
      data: current_prisoner_counts_data,
      text: current_prisoner_counts_text
    }
  end

  def self.current_prisoner_counts_sql(limit = nil)
    # this gets count by prison_id in format of {prison_id => count}
    counts = Incident.where(date_of_release: nil).order('count_all desc').limit(limit).group(:prison_id).count

    # get the prisons
    if I18n.locale == I18n.default_locale
      prisons = with_translations(I18n.locale).where(id: counts.keys)
    else
      prisons = with_translations(I18n.locale).with_translations(I18n.default_locale).where(id: counts.keys)
    end

    # now merge
    matches = []

    counts.keys.each do |prison_id|
      prison = prisons.find { |x| x.id == prison_id }
      matches << {
        prison_id: prison.id,
        slug: prison.slug,
        prison_name: prison.name,
        prisoner_count: counts[prison_id]
      }
    end

    matches
  end
end
