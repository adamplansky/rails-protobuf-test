# app/controllers/artists_controller.rb
class ArtistsController < ApplicationController  
    before_action :find_artist, only: [:show, :show_json]

    def index
      send_data Artist.serialize_all
    end

    def index_json
      render json: Artist.all
    end

    def show
      send_data @artist.serialize
    end

    def show_json
      render json: @artist
    end
  
    def find_artist
      @artist = Artist.find params[:id]
    end
  end  