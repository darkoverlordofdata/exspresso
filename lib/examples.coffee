#+--------------------------------------------------------------------+
#| examples.coffee
#+--------------------------------------------------------------------+
#| Copyright DarkOverlordOfData (c) 2012
#+--------------------------------------------------------------------+
#|
#| This file is a part of Exspresso
#|
#| Exspresso is free software; you can copy, modify, and distribute
#| it under the terms of the GNU General Public License Version 3
#|
#+--------------------------------------------------------------------+
#
#	examples - Main application
#
#
#
{Sql, CREATE, DISTINCT, DROP, FROM, GO, INNER, INSERT, INTO, IS, JOIN, LEFT, LIKE, LIMIT, OFFSET, ON, ORDER_BY, OUTER, RIGHT, SELECT, SET, UPDATE, USE, VALUES, WHERE} = require(FCPATH + 'lib/sql.dsl')



CREATE 'blog',
  title:                  Sql.STRING
  author:                 Sql.STRING
  description:            Sql.TEXT
,GO @dbforge, ($err) =>
  if $err
    console.log $err



CREATE 'customer',
  username:               Sql.STRING
  password:               Sql.STRING
  name:                   Sql.STRING
,GO @dbforge, ($err) =>
  if $err
    console.log $err


CREATE 'hotel',
  price:                  Sql.INTEGER
  name:                   Sql.STRING
  address:                Sql.STRING
  city:                   Sql.STRING
  state:                  Sql.STRING
  zip:                    Sql.STRING
  country:                Sql.STRING
,GO @dbforge, ($err) =>
  if $err
    console.log $err


CREATE 'booking',
  username:               Sql.STRING
  hotel:                  Sql.INTEGER
  checkinDate:            Sql.DATE
  checkoutDate:           Sql.DATE
  creditCard:             Sql.STRING
  creditCardName:         Sql.STRING
  creditCardExpiryMonth:  Sql.INTEGER
  creditCardExpiryYear:   Sql.INTEGER
  smoking:                Sql.STRING
  beds:                   Sql.INTEGER
  amenities:              Sql.STRING
  state:                  Sql.STRING
,GO @dbforge, ($err) =>
  if $err
    console.log $err

DROP TABLE 'blog', @dbforge, ($err) =>

ALTER TABLE 'blog',
ADD
  preferences: Sql.TEXT
,GO @dbforge, ($err) =>
  if $err
    console.log $err

ALTER TABLE 'blog',
CHANGE 'preference',
  preference: Sql.TEXT
,GO @dbforge, ($err) =>
  if $err
    console.log $err

ALTER TABLE 'blog',
RENAME TO 'blogette',
GO @dbforge, ($err) =>
  if $err
    console.log $err



SELECT 'Hotel.name', 'Hotel.address', 'Hotel.city', 'Hotel.state', 'Booking.checkinDate', 'Booking.checkoutDate', 'Booking.id',
FROM 'Booking',
WHERE 'Booking.state', IS 'BOOKED',
INNER JOIN 'Hotel', ON 'Hotel.id = Booking.hotel',
GO @db, ($err, $bookings) =>
  if $err
    console.log $err


SELECT '*',
FROM 'Hotel',
WHERE 'name', LIKE "%#{$searchString}%",
LIMIT $pageSize, OFFSET 0,
GO @db, ($err, $hotels) =>
  if $err
    console.log $err



SELECT '*',
FROM 'Hotel',
WHERE 'id', IS $id,
GO @db, ($err, $hotel) =>
  if $err
    console.log $err



SELECT '*',
FROM 'Hotel',
WHERE 'id', IS @req.param("hotelId"),
GO @db, ($err, $hotel) =>
  if $err
    console.log $err



SELECT '*',
FROM 'Hotel',
WHERE 'id', IS $id,
GO @db, ($err, $hotel) =>
  if $err
    console.log $err



INSERT INTO 'Booking',
['username', 'hotel', 'checkinDate', 'checkoutDate', 'creditCard', 'creditCardName', 'creditCardExpiryMonth', 'creditCardExpiryYear', 'smoking', 'beds', 'amenities', 'state'],
VALUES ['demo', $hotel.id, checkinDate, checkoutDate, creditCard, creditCardName, creditCardExpiryMonth, creditCardExpiryYear, smoking, beds, amenities, state],
GO @db, ($err) =>
  if $err
    console.log $err



SELECT '*',
FROM 'Booking',
WHERE 'id', IS $id,
GO @db, ($err, $booking) =>
  if $err
    console.log $err



UPDATE 'Booking',
WHERE 'id', IS $id,
SET $state,
GO @db, ($err) =>
  if $err
    console.log $err



UPDATE 'Booking',
WHERE 'id', IS $id,
SET $state,
GO @db, ($err) =>
  if $err
    console.log $err



SELECT '*',
FROM 'Hotel',
WHERE 'id', IS $booking.hotel,
GO @db, ($err, $hotel) =>
  if $err
    console.log $err






# End of file examples.coffee
# Location: ./examples.coffee