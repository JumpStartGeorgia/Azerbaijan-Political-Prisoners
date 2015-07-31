namespace :generated_files do
  desc 'Remove public/generated directory containing all generated files'
  task remove: :environment do
    GeneratedFile.remove
  end

  task generate: :environment do
    GeneratedFile.generate
  end

  task regenerate: :environment do
    GeneratedFile.regenerate
  end
end
