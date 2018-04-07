require_relative './lib/sql_object.rb'

class Artist < SQLObject
  has_many :albums

  has_many_through(:songs, :albums, :songs)
end

class Album < SQLObject
  belongs_to :band,
    foreign_key: :artist_id,
    class_name: "Artist"

  has_many :songs
end

class Song < SQLObject
  belongs_to :album

  has_one_through(:artist, :album, :band)
end
