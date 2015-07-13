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

def distance(a, b)
  Geocoder::Calculations.distance_between(a, b)
end

def centre(coords)
  Geocoder::Calculations.geographic_center(coords)
end

# To get your Instagram OAuth credentials, register an app at http://instagr.am/oauth/client/register/
credentials = JSON.load(open('.credentials'))
Instagram.configure do |config|
  config.client_id = credentials['client_id']
  config.client_secret = credentials['client_secret']
end

images = JSON.load(open('images.json'))['images']

images.map! do |sculpture|
  coords = sculpture[0]
  lat = coords[0]
  lng = coords[1]
  results = Instagram.media_search(lat, lng, distance: 10)
  puts "#{results.count} found \n"
  new_images = []
  existing_images = sculpture[1] || []
  results.each do |media|
    started = Date.parse('6th July 2015').to_time
    created = Time.at media.created_time.to_i
    next unless created > started
    # Append if it isn't a duplicate
    unless existing_images.map { |x| x[0] }.include? media.link
      new_images << [media.link, media.images.thumbnail.url]
    end
  end
  sculpture[1] = (existing_images + new_images)
  open('images.json', 'w') do |f|
    f.puts JSON.pretty_generate(images: images)
  end
  sleep 0.5 # Crude rate limit protection
  sculpture
end
