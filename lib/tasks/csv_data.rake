namespace :db do
  desc 'Output application data to CSV.'
  task :export_to_csv do
    require 'csv_data'
    DataToCSV.output
  end
end