buildPlist = "#{ENV['SRCROOT']}/#{ENV['INFOPLIST_FILE']}"
CFBundleShortVersionString = `/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" #{buildPlist}`.chomp
appPath = File.join(ENV['ARCHIVE_PATH'], 'Products/Applications')
appName = ENV['PRODUCT_NAME']

exec %(
       cd "#{appPath}"
       test -f *.dmg && rm *.dmg
       bash #{ENV['SRCROOT']}/ExternalDeps/yoursway-create-dmg/create-dmg --window-size 603 512 --window-pos 150 250 --background #{ENV['SRCROOT']}/Artwork/dmg-bg.tiff --icon-size 128 --volname "#{appName} v#{CFBundleShortVersionString}" --icon "#{appName}" 130 280 --app-drop-link 432 160 #{appName}-v#{CFBundleShortVersionString}.dmg .
       )
