# Luckily bristol-culture.com have gone out and photographed every gromit
# and put a picture of each with name/artist/location underneath.
# Doesn't quite work though, need to hand edit the names of two of them.

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
