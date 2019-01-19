# frozen_string_literal: true

# class Artist < ApplicationRecord
# end
# app/models/artist.rb
# class Artist < ActiveRecord::Base
class Artist < ApplicationRecord
  # has_many :venues

  ###
  # Create a model from a message object
  def self.from_message(message)
    Artist.new.tap do |a|
      a.id = message.id
      a.name = message.name
      a.bio = message.bio
      a.genre = message.genre
    end
  end

  ###
  # Create a message object from model
  def to_message
    ArtistMessage.new(
      id: id,
      name: name,
      bio: bio,
      genre: genre
    )
  end

  ###
  # Encode model data in protobuf format
  def serialize
    ArtistMessage.encode(to_message)
  end

  ###
  # Decode protobuf data and hydrate model
  def unserialize(data)
    message = ArtistMessage.decode(data)
    Artist.from_message(message)
  end

  ###
  # Encode all models to ArtistCollectionMessage
  # protobuf message
  def self.serialize_all
    message = ArtistCollectionMessage.new(
      artists: Artist.all.map(&:to_message)
    )
    ArtistCollectionMessage.encode(message)
  end

  ###
  # Decode a ArtistCollectionMessage protobuf
  # to a collection of Artist models
  def self.unserialize_all(data)
    message = ArtistCollectionMessage.decode(data)
    message.artists.map do |a|
      Artist.from_message(a)
    end
  end
  end
