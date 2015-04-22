# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def self.create_roles
  roles = ['super_admin', 'site_admin', 'user_manager']
  roles.each do |role|
    Role.find_or_create_by({name: role})
  end
end

create_roles
