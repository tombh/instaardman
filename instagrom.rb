# Find all the images near the gromits

# Attributes for a media object in the Instagram API
#
# attribution
# tags
# location
# comments
# filter
# created_time
# link
# likes
# images
# users_in_photo
# caption
# type
# id
# user

require 'rubygems'
require 'instagram'
require 'json'
require 'geocoder'

Geocoder.configure(units: :km)

def distance a, b
  Geocoder::Calculations.distance_between(a, b)
end

def centre coords
  Geocoder::Calculations.geographic_center(coords)
end

# To get your Instagram OAuth credentials, register an app at http://instagr.am/oauth/client/register/
credentials = JSON.load(open('.credentials'))
Instagram.configure do |config|
  config.client_id = credentials["client_id"]
  config.client_secret = credentials["client_secret"]
end

gromits = JSON.load(open('gromits.json'))

images = []

gromits.each do |gromit|
  puts "Searching #{gromit['name']}"
  lat = gromit['coords'][0]
  lng = gromit['coords'][1]
  results = Instagram.media_search(lat, lng, :distance => 10)
  puts "#{results.count} found \n"
  i = []
  results.each do |media|
     i << media.images.standard_resolution.url
  end
  images << [[lat, lng], i]
  open('images.json', 'w') do |f|
    f.puts JSON.pretty_generate(images)
  end
  sleep 0.5 # Crude rate limit protection
end
