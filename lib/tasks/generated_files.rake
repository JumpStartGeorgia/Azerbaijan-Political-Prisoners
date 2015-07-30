namespace :generated do
  desc 'Remove public/generated directory containing all generated files'
  task remove: :environment do
    require 'fileutils'
    FileUtils.rm_rf(Rails.root.join('public', 'generated'))
  end
end
