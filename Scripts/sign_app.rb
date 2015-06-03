#!/usr/bin/env ruby

def find_codesign_identity
  look_for = "Developer ID Application"
  identities = `xcrun security find-identity -v -p codesigning`.split("\n")

  identity = identities.grep(/#{look_for}/).last
  raise "Identity matching '#{look_for}' not found." unless identity

  match = identity.match(/\"(.*)\"/)
  raise "Identity matching '#{look_for}' was found but it is probably not what we are looking for. Found: '#{identity}'." unless match

  return match[1]
end

codesign_identity = find_codesign_identity

Dir["*.app", "*.app/**/Frameworks/*.framework"].sort { |a, b| b <=> a }.map { |f| f }.each do |d|
  `xcrun codesign -f -s '#{codesign_identity}' -vvvv #{d}`
end
