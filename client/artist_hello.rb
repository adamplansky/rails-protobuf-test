# Use the class methods to get down to business quickly
require 'httparty'
require_relative 'artist_message_pb.rb'
require_relative 'artist_collection_message_pb.rb'
require 'benchmark'

# response = HTTParty.get('http://api.stackexchange.com/2.2/questions?site=stackoverflow')

# puts response.body, response.code, response.message, response.headers.inspect

# Or wrap things up in your own class
class Protobuf
  include HTTParty
  base_uri 'localhost:3000'

  def initialize(service, page)
    @options = { query: { site: service, page: page } }
  end

  def artist(id)
    self.class.get("/artists/#{id}")
  end

  def artist_json(id)
    self.class.get("/artists/show_json/#{id}")
  end

  def artists
    self.class.get('/artists')
  end

  def artists_json
    self.class.get('/artists/index_json')
  end
end

# ----------------------------------------------------------
class Artist
  attr_accessor :id, :name, :bio, :genre

  def to_hash
    hash = {}
    instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
    hash
  end
  ###
  # Create a model from a message object
  def self.show_deser_proto(data)
    message = ArtistMessage.decode(data)
    a = Artist.new
    a.id = message.id
    a.name = message.name
    a.bio = message.bio
    a.genre = message.genre
    a
  end

  def self.show_deser_json(data)
    message = JSON.parse(data, symbolize_names: true)
    a = Artist.new
    a.id = message[:id]
    a.name = message[:name]
    a.bio = message[:bio]
    a.genre = message[:genre]
    a
  end

  def self.index_deser_proto(data)
    message = ArtistCollectionMessage.decode(data)
    message.artists.map do |message|
      a = Artist.new
      a.id = message.id
      a.name = message.name
      a.bio = message.bio
      a.genre = message.genre
      a
    end
  end

  def self.index_deser_json(data)
    message = JSON.parse(data, symbolize_names: true)
    message.map do |message|
      a = Artist.new
      a.id = message[:id]
      a.name = message[:name]
      a.bio = message[:bio]
      a.genre = message[:genre]
      a
    end
  end
end

stack_exchange = Protobuf.new('stackoverflow', 1)
artist = stack_exchange.artist_json(1)
ar = Artist.show_deser_json(artist.body).to_hash

# pp JSON.dump ar #returns a JSON string
# pp JSON.generate ar #returns a JSON string
# pp ar.to_json #returns a JSON string

Benchmark.bm do |x|
  n = 400
  puts '400x iterating array with 1002 elements'
  puts 'protobuf:'
  x.report do
    response_avg = 0 
    (1..n).each do |_i|
      response = stack_exchange.artists
      Artist.index_deser_proto(response.body).count
      response_avg += response.headers["x-runtime"].to_f
    end
    puts "avg_response: #{response_avg / n}"
  end
  puts 'json:'
  x.report do
    response_avg = 0 
    (1..n).each do |_i|
      response = stack_exchange.artists_json
      Artist.index_deser_json(response.body).count
      response_avg += response.headers["x-runtime"].to_f
    end
    puts "avg_response: #{response_avg / n}"
  end
  n = 10_000
  puts 'protobuf:'
  puts 'iterating 10000x single object "{\"id\":1,\"name\":\"Adam\",\"bio\":\"bio\",\"genre\":\"muz\"}"'
  x.report do
    response_avg = 0 
    (1..n).each do |_i|
      response = stack_exchange.artist(1)
      Artist.show_deser_proto(response.body)
      response_avg += response.headers["x-runtime"].to_f
    end
    puts "avg_response: #{response_avg / n}"
  end
  puts 'json:'
  x.report do
    response_avg = 0 
    (1..n).each do |_i|
      response = stack_exchange.artist_json(1)
      Artist.show_deser_json(response.body)
      response_avg += response.headers["x-runtime"].to_f
    end
    puts "avg_response: #{response_avg / n}"
  end
end

# n = 10
# Benchmark.bm do |x|
#   puts "protobuf:"
#   x.report do
#     for i in 1..n do
#       artist = stack_exchange.artist(1)
#       Artist.from_message(artist.body)
#     end
#   end
#   puts "json:"
#   x.report do
#     for i in 1..n do
#       artist = stack_exchange.artists_json(1)
#       Artist.from_json_message(artist.body)
#     end
#   end
#   #  x.report { n.times do ; Artist.from_json_message(artist.body); end }
# end
# artist = stack_exchange.artist(1)
# artist = stack_exchange.artist(1)
# # puts artist.body
# # puts ArtistMessage.decode(artist.body)
# Artist.from_message(artist.body)

# puts '-----------------------------'
# artist = stack_exchange.artists_json(1)
# Artist.from_json_message(artist.body)
# # puts artist.body
# # puts ArtistMessage.decode(artist.body)
# # a = Artist.unserialize(artist.body)
