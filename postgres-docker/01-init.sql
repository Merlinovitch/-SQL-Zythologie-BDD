-- Créer les tables
CREATE TABLE beerlover (
    beerlover_id SERIAL PRIMARY KEY,
    beerlover_name VARCHAR(50),
    beerlover_mail VARCHAR(50),
    beerlover_password VARCHAR(50)
);

CREATE TABLE brewery (
    brewery_id SERIAL PRIMARY KEY,
    brewery_name VARCHAR(50),
    brewery_country VARCHAR(50)
);

CREATE TABLE beer (
   beer_id SERIAL PRIMARY KEY,
   beer_name VARCHAR(50),
   beer_description VARCHAR(2000),
   beer_abv FLOAT,
   brewery_id INT,
   FOREIGN KEY (brewery_id) REFERENCES brewery(brewery_id)
);

CREATE TABLE review (
    review_id SERIAL PRIMARY KEY,
    review_note INT NOT NULL,
    review_comment VARCHAR(500),
    beer_id INT,
    beerlover_id INT,
    FOREIGN KEY (beer_id) REFERENCES beer(beer_id),
    FOREIGN KEY (beerlover_id) REFERENCES beerlover(beerlover_id)
);

CREATE TABLE photo (
   photo_id SERIAL PRIMARY KEY,
   photo_url VARCHAR(200),
   photo_alt VARCHAR(100),
   beer_id INT, 
   FOREIGN KEY (beer_id) REFERENCES beer(beer_id)
);

CREATE TABLE ingredient (
  ingredient_id SERIAL PRIMARY KEY, 
  ingredient_name VARCHAR(50)
); 

CREATE TABLE favorite (
  beerlover_id INT, 
  beer_id INT, 
  PRIMARY KEY(beerlover_id, beer_id), 
  FOREIGN KEY(beerlover_id) REFERENCES beerlover(beerlover_id), 
  FOREIGN KEY(beer_Id) REFERENCES beer(beer_id)
); 

CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  category_name VARCHAR(50)
); 

CREATE TABLE category_beer (
  category_id INT,  
  beer_id INT,     
  FOREIGN KEY(category_id) REFERENCES category(category_id),   
  FOREIGN KEY(beer_id) REFERENCES beer(beer_id)
);

CREATE TABLE beer_ingredient (
  beer_id INT, 
  ingredient_id INT, 
  PRIMARY KEY(beer_id, ingredient_id),  
  FOREIGN KEY(beer_id) REFERENCES beer(beer_id),  
  FOREIGN KEY(ingredient_id) REFERENCES ingredient(ingredient_id)
); 