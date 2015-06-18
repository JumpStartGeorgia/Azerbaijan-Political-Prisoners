class Tag < ActiveRecord::Base
  extend FriendlyId

  has_and_belongs_to_many :incidents
  validates :name, presence: true, uniqueness: true

  # strip extra spaces before saving
  auto_strip_attributes :name, :description

  # permalink
  friendly_id :name, use: :history

  def self.to_csv
    require 'csv'

    CSV.generate do |csv|
      csv << %w(Name Description)
      all.each do |tag|
        csv << [tag.name, tag.description]
      end
    end
  end

  # include the current prisoner count with the tags
  def self.with_current_and_all_prisoner_count(tag_id = nil)
    # this old query counts number of incidents, not people
    # sql = 'select t.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count from tags as t left join (select tag_id, count(*) as count from incidents_tags group by tag_id) as i_all on i_all.tag_id = t.id left join (select tag_id, count(*) as count from incidents_tags as it inner join incidents as i on i.id = it.incident_id where i.date_of_release is null group by it.tag_id) as i_current on i_current.tag_id = t.id'
    sql = 'select t.*, if(i_current.count is null, 0, i_current.count) as current_prisoner_count, if(i_all.count is null, 0, i_all.count) as all_prisoner_count  from tags as t  left join (select x.tag_id, count(*) as count  from (select it.tag_id from incidents_tags as it  inner join incidents as i on i.id = it.incident_id  group by it.tag_id, i.prisoner_id) as x group by x.tag_id) as i_all on i_all.tag_id = t.id  left join (select tag_id, count(*) as count from incidents_tags as it inner join incidents as i on i.id = it.incident_id where i.date_of_release is null group by it.tag_id) as i_current on i_current.tag_id = t.id'

    sql << ' where t.id = ?' if tag_id.present?
    find_by_sql([sql, tag_id])
  end
end
