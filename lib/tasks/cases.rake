namespace :case do
  task :import, [:filename] => [:environment] do |t, args|
    # puts ARGV.inspect
    puts args[:filename]
    if args[:filename].to_s.empty?
      puts "filename parameter is required"
      exit
    end

    file = File.open(args[:filename])
    CsvImporter.import(file)
  end
end
