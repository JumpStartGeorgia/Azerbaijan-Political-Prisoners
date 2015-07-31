namespace :generated_files do
  desc 'Remove public/generated directory containing all generated files'
  task remove: :environment do
    GeneratedFiles.remove
  end

  task generate: :environment do
    GeneratedFiles.generate
  end

  task regenerate: :environment do
    GeneratedFiles.regenerate
  end
end
