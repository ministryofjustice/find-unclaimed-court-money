namespace :case do
  desc "import cases"
  task :import, [:filename] => [:environment] do |_, args|
    puts args[:filename]
    if args[:filename].to_s.empty?
      puts "filename parameter is required"
      exit
    end

    file = File.open(args[:filename])
    CsvImporter.import(file)
  end
end
