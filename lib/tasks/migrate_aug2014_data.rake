namespace :aug2014_data do
  desc 'Transfer the data from the August 2014 Azeri Prisoner List (stored at lib/aug2014PdfParser/input/list.html) into Rails database'
  task :migrate => :environment do
    puts 'Resetting database.'
    Rake::Task["db:reset"].invoke

    puts 'Parsing Azeri prisoner list data into lib/aug2014PdfParser/output'
    require 'aug2014PdfParser/src/parser'
    Aug2014ListParser.parse
    puts 'Finished parsing Azeri prisoner list data into lib/aug2014PdfParser/output'

    puts 'Migrating Azeri prisoner list data from lib/aug2014PdfParser/output into database; also transferring portraits from lib/aug2014PdfParser/portraits into public/system/images/prisoners/portraits'
    require 'aug2014DataToDb'
    Aug2014DataToDb.migrate
    puts 'Finished prisoner list data into database and portraits into public/system/images/prisoners/portraits'
  end
end
