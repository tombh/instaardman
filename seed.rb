# Seed images.json with an array of coords
require 'json'

out = []
sculptures = JSON.load(open('sculptures.json'))['sculptures']

sculptures.each do |sculpture|
  # Unfortunately the coords aren't consistenly formatted.
  # Sometimes they're with brackets, eg; "[51.520881,-0.080382]" and sometimes
  # not, eg; "51.520881,-0.080382",
  without_brackets = sculpture['location'].gsub('[', '').gsub(']', '')
  item = []
  item << without_brackets.split(',').map(&:to_f)
  item << [] # Placeholder for instagram images
  out << item
end

open('images.json', 'w') do |f|
  out = { images: out }
  f.puts JSON.pretty_generate(out)
end
