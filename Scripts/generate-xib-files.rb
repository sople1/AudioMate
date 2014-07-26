require 'Benchmark'

# READ: http://www.bdunagan.com/2009/03/15/ibtool-localization-made-easy/

# Generate the Localizable.strings file
# genstrings -o en.lproj *.m

# Generate strings from XIB
# ibtool --generate-strings-file en.lproj/MainMenu.strings en.lproj/MainMenu.xib

# Generate lang.lproj/SomeView.xib using lang.lproj/SomeView.strings and master XIB
# ibtool --strings-file es.lproj/ProfilesView.strings --write es.lproj/ProfilesView.xib en.lproj/ProfilesView.xib

# ---
# Edit the views to generate and languages here

xibFiles = %w(MainMenu)
baseLang = "en"
languages = %w(es ja zh-Hans zh-Hant)

# ---

# Generator below

puts "Base language: #{baseLang}"
puts "Languages to process: #{languages.join(", ")}"
puts "XIB files to process: #{xibFiles.join(", ")}"
puts

totalTimeBenchmark = Benchmark.measure do
    languages.each do |lang|
        xibFiles.each do |xibFile|
            begin
                command = "ibtool --import-strings-file #{lang}.lproj/#{xibFile}.strings --write #{lang}.lproj/#{xibFile}.xib #{baseLang}.lproj/#{xibFile}.xib"
                #puts "=> #{command}"
                puts sprintf("** #{lang}.lproj/#{xibFile}.xib generated in %.2fs", Benchmark.measure { |m| puts %x(#{command}) }.real)

            rescue Errno::ENOENT
                puts "Error in #{$?}"
                exit 1
            end
        end
    end
end

puts
puts sprintf("Total processing time: %.2fs", totalTimeBenchmark.real)
