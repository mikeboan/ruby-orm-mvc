require_relative './lib/sql_object.rb'

class Artist < SQLObject

  has_many :albums

end

class Album < SQLObject

  belongs_to :band,
    foreign_key: :artist_id,
    class_name: "Artist"

end
