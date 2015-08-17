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

  ############################################################
  ############### Current prisoner count chart ###############

  def self.summary(prisoner_count, prison_name)
    I18n.t('prison.current_prisoner_count_chart.summary',
           number_prisoners: "<strong>#{prisoner_count}</strong>",
           prison_name: "<strong>#{prison_name}</strong>",
           count: prisoner_count
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

  def self.current_prisoner_counts_data(limit = nil)
    # this gets count by prison_id in format of {prison_id => count}
    counts = Incident.where(date_of_release: nil).order('count_all desc').limit(limit).group(:prison_id).count

    # get the prisons with current locale translations, plus default locale
    # translations as fallback
    prisons = preload(:translations).where(id: counts.keys)

    # Combine count and translations
    prisons_data = []

    counts.keys.each do |prison_id|
      prison = prisons.find { |prison| prison.id == prison_id }
      prisoner_count = counts[prison_id]

      prisons_data.append(
        y: prisoner_count,
        name: prison.name,
        link: Rails.application.routes.url_helpers
          .prison_path(prison, locale: I18n.locale),
        summary: summary(prisoner_count, prison.name)
      )
    end

    prisons_data
  end

  def self.current_prisoner_counts
    {
      data: current_prisoner_counts_data(10),
      text: current_prisoner_counts_text
    }
  end

  def self.generate_current_prisoner_counts_chart_json(prisoner_counts_chart_json_path)
    # if folder path not exist, create it
    FileUtils.mkdir_p(Pathname.new(
                        File.dirname(prisoner_counts_chart_json_path)))

    File.open(prisoner_counts_chart_json_path, 'w') do |f|
      f.write(current_prisoner_counts.to_json)
    end
  end

  def self.current_prisoner_counts_chart_json
    prisoner_counts_chart_json_path =
      Rails.public_path.join('generated',
                             'json',
                             I18n.locale.to_s,
                             'prison_prisoner_count_chart.json')

    unless File.exist?(prisoner_counts_chart_json_path)
      generate_current_prisoner_counts_chart_json(prisoner_counts_chart_json_path)
    end

    prisoner_counts_chart_json_path
  end

  ############################################################

  # include the current prisoner count with the prisons
  def self.with_current_and_all_prisoner_count(prison_id = nil)
    # this old query counts number of incidents, not people
    # sql = 'select p.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count from prisons as p left join (select prison_id, count(*) as count from incidents group by prison_id) as i_all on i_all.prison_id = p.id left join (select prison_id, count(*) as count from incidents where date_of_release is null group by prison_id) as i_current on i_current.prison_id = p.id'
    sql = 'select p.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count  from prisons as p  left join (select x.prison_id, count(*) as count from  (select prison_id from incidents group by prison_id,prisoner_id) as x group by x.prison_id) as i_all on i_all.prison_id = p.id  left join (select prison_id, count(*) as count from incidents where date_of_release is null group by prison_id) as i_current on i_current.prison_id = p.id'
    sql << ' where p.id = ?' if prison_id.present?
    find_by_sql([sql, prison_id])
  end
end
