# Doesn't quite work, need to hand edit the names of two of them.

require 'nokogiri'
require 'open-uri'
require 'json'

uri = "http://www.bristol-culture.com/gromit-unleashed"
ps = Nokogiri::HTML(open(uri)).search('.entry p')

gromits = []

ps.each do |p|
  next unless !p.text.empty?
  gromits << {
    no: p.text.scan(/^(\d+)\)/)[0][0],
    name: p.text.scan(/^\d+\)(.*)\(/)[0][0].strip,
    artist: p.text.scan(/^\d+\).*\((.*)\)/)[0][0].strip,
    location: p.text.scan(/^\d+\).*\(.*\):(.*)/)[0][0].strip,
  }
end

open('gromits.json', 'w') do |f|
  f.puts JSON.pretty_generate(gromits)
end
