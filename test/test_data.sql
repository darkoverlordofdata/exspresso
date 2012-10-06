delimiter $$

CREATE TABLE `booking` (
  `username` varchar(255) DEFAULT NULL,
  `hotel` int(11) DEFAULT NULL,
  `checkinDate` datetime DEFAULT NULL,
  `checkoutDate` datetime DEFAULT NULL,
  `creditCard` varchar(255) DEFAULT NULL,
  `creditCardName` varchar(255) DEFAULT NULL,
  `creditCardExpiryMonth` int(11) DEFAULT NULL,
  `creditCardExpiryYear` int(11) DEFAULT NULL,
  `smoking` varchar(255) DEFAULT NULL,
  `beds` int(11) DEFAULT NULL,
  `amenities` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1$$

delimiter $$

CREATE TABLE `customer` (
  `username` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1$$

delimiter $$

CREATE TABLE `hotel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `price` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1$$



INSERT INTO `customer` (username, name) values ('keith', 'Keith');
INSERT INTO `customer` (username, name) values ('erwin', 'Erwin');
INSERT INTO `customer` (username, name) values ('jeremy', 'Jeremy');
INSERT INTO `customer` (username, name) values ('scott', 'Scott');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (1, 199, 'Westin Diplomat', '3555 S. Ocean Drive', 'Hollywood', 'FL', '33019', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (2, 60, 'Jameson Inn', '890 Palm Bay Rd NE', 'Palm Bay', 'FL', '32905', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (3, 199, 'Chilworth Manor', 'The Cottage, Southampton Business Park', 'Southampton', 'Hants', 'SO16 7JF', 'UK');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (4, 120, 'Marriott Courtyard', 'Tower Place, Buckhead', 'Atlanta', 'GA', '30305', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (5, 180, 'Doubletree', 'Tower Place, Buckhead', 'Atlanta', 'GA', '30305', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (6, 450, 'W hotel', 'Union Square, Manhattan', 'NY', 'NY', '10011', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (7, 450, 'W hotel', 'Lexington Ave, Manhattan', 'NY', 'NY', '10011', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (8, 250, 'hotel Rouge', '1315 16th Street NW', 'Washington', 'DC', '20036', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (9, 300, '70 Park Avenue hotel', '70 Park Avenue', 'NY', 'NY', '10011', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (10, 300, 'Conrad Miami', '1395 Brickell Ave', 'Miami', 'FL', '33131', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (11, 80, 'Sea Horse Inn', '2106 N Clairemont Ave', 'Eau Claire', 'WI', '54703', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (12, 90, 'Super 8 Eau Claire Campus Area', '1151 W Macarthur Ave', 'Eau Claire', 'WI', '54701', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (13, 160, 'Marriot Downtown', '55 Fourth Street', 'San Francisco', 'CA', '94103', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (14, 200, 'Hilton Diagonal Mar', 'Passeig del Taulat 262-264', 'Barcelona', 'Catalunya', '08019', 'Spain');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (15, 210, 'Hilton Tel Aviv', 'Independence Park', 'Tel Aviv', '', '63405', 'Israel');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (16, 240, 'InterContinental Tokyo Bay', 'Takeshiba Pier', 'Tokyo', '', '105', 'Japan');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (17, 130, 'hotel Beaulac', ' Esplanade L�opold-Robert 2', 'Neuchatel', '', '2000', 'Switzerland');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (18, 140, 'Conrad Treasury Place', 'William & George Streets', 'Brisbane', 'QLD', '4001', 'Australia');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (19, 230, 'Ritz Carlton', '1228 Sherbrooke St', 'West Montreal', 'Quebec', 'H3G1H6', 'Canada');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (20, 460, 'Ritz Carlton', 'Peachtree Rd, Buckhead', 'Atlanta', 'GA', '30326', 'USA');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (21, 220, 'Swissotel', '68 Market Street', 'Sydney', 'NSW', '2000', 'Australia');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (22, 250, 'Meli� White House', 'Albany Street', 'Regents Park London', '', 'NW13UP', 'Great Britain');
INSERT INTO `hotel` (id, price, name, address, city, state, zip, country) values (23, 210, 'hotel Allegro', '171 West Randolph Street', 'Chicago', 'IL', '60601', 'USA');