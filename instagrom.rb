require "rubygems"
require "instagram"
require 'json'
require 'geocoder'
require 'amatch'
include Amatch

# Geocoder.configure(units: :km)

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

# Attributes for a media object in the API
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

gromits = JSON.load(open('gromits.json'))

# If you make a mistake you can edit the JSON
# edited = []
# gromits.each do |g|
#   g.delete("coords")
#   edited << g
# end
# open('gromits.json', 'w') do |f|
#   f.puts JSON.pretty_generate(edited)
# end
# exit

names = gromits.map{|g| g["name"]}

hotspots = JSON.load(open('hotspots.json'))

page = Instagram.tag_recent_media("gromit")
until page.pagination.next_max_id.nil?
  page.each do |media|
    sleep 1 # Crude rate limit protection
    if media.location

      # See if we can cleverely string match any
      canditates = []
      tags = media.tags - ["gromit"] - ["uk"]
      patterns = media.comments.data.map{|c| c.text} + tags
      names.each do |name|
        m = Levenshtein.new(name)
        best_candidate = m.match(patterns).zip(patterns).sort_by{|score, tag| score}.first
        next if best_candidate.nil?
        canditates << [name, best_candidate[0]]
      end

      coords = [media.location.latitude, media.location.longitude]

      # If we can identify this gromit
      canditate = canditates.sort_by{|name, score| score}.first
      if !canditate.nil?
        canditate_name = canditate[0]
        canditate_score = canditate[1]
        if canditate_score <= 3
          # Get the gromit number from the gromits array
          gromit = gromits.select{|g| g["name"] == canditate_name}.first["no"].to_i - 1
          # Update its coords
          if gromits[gromit]["coords"]
            if distance(gromits[gromit]["coords"], coords) < 0.01 # 10 meters
              # Improve coords by averaging duplicates
              gromits[gromit]["coords"] = centre([gromits[gromit]["coords"], coords])
            end
          else
            gromits[gromit]["coords"] = coords
          end
          puts "------------"
          puts "MATCH"
          puts "#{media.images.standard_resolution.url}"
          puts "#{patterns}"
          puts "#{canditate_score}"
          puts "#{canditate_name}"
          puts "#{gromits[gromit]['coords']}"
          count = gromits.select{|g| g.has_key?('coords')}.length
          puts "#{count}/80"
          puts "------------\n\n"
          open('gromits.json', 'w') do |f|
            f.puts JSON.pretty_generate(gromits)
          end
        end
      end

      # All canditates, whether we can identify them or not
      hotspots_tmp = []
      hotspots = [[coords, 1, [media.images.standard_resolution.url]]] if hotspots.nil? || hotspots.length == 0
      puts "--------------"
      puts "NO MATCH"
      puts "#{media.location}"
      nearby_found = false
      hotspots.each do |hotspot|
        hotspot_coords, weight, images = hotspot
        d = distance(hotspot_coords, coords)
        puts d
        if d < 0.01
          nearby_found = true
          images << media.images.standard_resolution.url
          # Average the coords into the hotspot and inc the weight
          hotspots_tmp << [centre([hotspot_coords, coords]), weight + 1, images]
          puts "Merged"
        else
          # Put the tested hotspot back
          hotspots_tmp << [hotspot_coords, weight, images]
        end
      end
      puts "--------------"
      # Append the coords if no match was found
      hotspots_tmp << [coords, 1, [media.images.standard_resolution.url]] if !nearby_found
      hotspots = hotspots_tmp
      open('hotspots.json', 'w') do |f|
        f.puts JSON.pretty_generate(hotspots)
      end

    end
  end
  page = Instagram.tag_recent_media("gromit", max_id: page.pagination.next_max_id)
end

