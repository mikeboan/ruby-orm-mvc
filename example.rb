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

class User < SQLObject
  has_many :owned_groups,
    foreign_key: :admin_id,
    class_name: 'Group'

  has_many :memberships

  has_many :groups, through: :memberships, source: :groups
end

class Membership < SQLObject
  belongs_to :user
  belongs_to :group
end

class Group < SQLObject
  belongs_to :admin,
    class_name: 'User',
    foreign_key: :admin_id

  has_many :memberships

  has_many :users, through: :memberships

  # groups my admin also owns
  has_many :sibling_groups, through: :admin, source: :owned_groups
end
