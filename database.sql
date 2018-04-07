DROP TABLE IF EXISTS artists;

CREATE TABLE artists (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS albums;

CREATE TABLE albums (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  album_art_url VARCHAR(255),
  artist_id INTEGER,

  FOREIGN KEY(artist_id) REFERENCES artists(id)
);

DROP TABLE IF EXISTS songs;

CREATE TABLE songs (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  album_id INTEGER NOT NULL,

  FOREIGN KEY(album_id) REFERENCES albums(id)
);

INSERT INTO
  artists (id, name)
VALUES
  (1, "The Beatles"), (2, "Radiohead");

INSERT INTO
  albums (id, title, album_art_url, artist_id)
VALUES
  (1, "Abbey Road", "https://upload.wikimedia.org/wikipedia/en/4/42/Beatles_-_Abbey_Road.jpg", 1),
  (2, "Let It Be", "https://upload.wikimedia.org/wikipedia/en/2/25/LetItBe.jpg", 1),
  (3, "OK Computer", "https://upload.wikimedia.org/wikipedia/en/a/a1/Radiohead.okcomputer.albumart.jpg", 2),
  (4, "In Rainbows", "https://upload.wikimedia.org/wikipedia/en/2/2e/In_Rainbows_Official_Cover.jpg", 2);

INSERT INTO
  songs (id, title, album_id)
VALUES
  ( 1, "Airbag", 3),
  ( 2, "Paranoid Android", 3),
  ( 3, "Subterranean Homesick Alien", 3),
  ( 4, "Exit Music (For a Film),", 3),
  ( 5, "Let Down", 3),
  ( 6, "Karma Police", 3),
  ( 7, "Fitter Happier", 3),
  ( 8, "Electioneering", 3),
  ( 9, "Climbing Up the Walls", 3),
  (10, "No Surprises", 3),
  (11, "Lucky", 3),
  (12, "The Tourist", 3),
  (13, "15 Step", 4),
  (14, "Bodysnatchers", 4),
  (15, "Nude", 4),
  (16, "Weird Fishes/Arpeggi", 4),
  (17, "All I Need", 4),
  (18, "Faust Arp", 4),
  (19, "Reckoner", 4),
  (20, "House of Cards", 4),
  (21, "Jigsaw Falling into Place", 4),
  (22, "Videotape", 4),
  (23, "Come Together", 1),
  (24, "Something", 1),
  (25, "Maxwell's Silver Hammer", 1),
  (26, "Oh! Darling", 1),
  (27, "Octopus's Garden", 1),
  (28, "I Want You (She's So Heavy)", 1),
  (29, "Here Comes the Sun", 1),
  (30, "Because", 1),
  (31, "Medley", 1),
  (32, "Her Majesty", 1),
  (33, "Two of Us", 2),
  (34, "Dig a Pony", 2),
  (35, "Across the Universe", 2),
  (36, "I Me Mine", 2),
  (37, "Dig It", 2),
  (38, "Let It Be", 2),
  (39, "Maggie Mae", 2),
  (40, "I've Got a Feeling", 2),
  (41, "One After 909", 2),
  (42, "The Long and Winding Road", 2),
  (43, "For You Blue", 2),
  (44, "Get Back", 2);



DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS memberships;

CREATE TABLE memberships (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  group_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES users(id)
  FOREIGN KEY(group_id) REFERENCES groups(id)
);

DROP TABLE IF EXISTS groups;

CREATE TABLE groups (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  admin_id INTEGER NOT NULL,

  FOREIGN KEY(admin_id) REFERENCES users(id)
);

INSERT INTO
  users (id, name)
VALUES
  (1, "User 1"), (2, "User 2"), (3, "User 3");

INSERT INTO
  groups (id, title, admin_id)
VALUES
  (1, "First Group", 1),
  (2, "Second Group", 1),
  (3, "Third Group", 2);

INSERT INTO
  memberships (id, user_id, group_id)
VALUES
  (1, 1, 1),
  (2, 1, 2),
  (3, 2, 3),
  (4, 2, 2),
  (5, 3, 3);
