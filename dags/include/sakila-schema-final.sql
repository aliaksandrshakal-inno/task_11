
CREATE SCHEMA IF NOT EXISTS sakila;
SET search_path TO sakila, public;

-- Trigger function for last_update
CREATE OR REPLACE FUNCTION sakila.set_last_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_update = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tables
DROP TABLE IF EXISTS sakila.actor CASCADE;
CREATE TABLE sakila.actor (
  actor_id SERIAL PRIMARY KEY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.country CASCADE;
CREATE TABLE sakila.country (
  country_id SERIAL PRIMARY KEY,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.city CASCADE;
CREATE TABLE sakila.city (
  city_id SERIAL PRIMARY KEY,
  city VARCHAR(50) NOT NULL,
  country_id INT NOT NULL REFERENCES sakila.country(country_id),
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.address CASCADE;
CREATE TABLE sakila.address (
  address_id SERIAL PRIMARY KEY,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50),
  district VARCHAR(20) NOT NULL,
  city_id INT NOT NULL REFERENCES sakila.city(city_id),
  postal_code VARCHAR(10),
  phone VARCHAR(20) NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.category CASCADE;
CREATE TABLE sakila.category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.language CASCADE;
CREATE TABLE sakila.language (
  language_id SERIAL PRIMARY KEY,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.film CASCADE;
CREATE TABLE sakila.film (
  film_id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  release_year INT,
  language_id INT NOT NULL REFERENCES sakila.language(language_id),
  original_language_id INT REFERENCES sakila.language(language_id),
  rental_duration SMALLINT DEFAULT 3 NOT NULL,
  rental_rate NUMERIC(4,2) DEFAULT 4.99 NOT NULL,
  length SMALLINT,
  replacement_cost NUMERIC(5,2) DEFAULT 19.99 NOT NULL,
  rating VARCHAR(10) DEFAULT 'G',
  special_features TEXT,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.film_actor CASCADE;
CREATE TABLE sakila.film_actor (
  actor_id INT NOT NULL REFERENCES sakila.actor(actor_id),
  film_id INT NOT NULL REFERENCES sakila.film(film_id),
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (actor_id, film_id)
);

DROP TABLE IF EXISTS sakila.film_category CASCADE;
CREATE TABLE sakila.film_category (
  film_id INT NOT NULL REFERENCES sakila.film(film_id),
  category_id INT NOT NULL REFERENCES sakila.category(category_id),
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id, category_id)
);

DROP TABLE IF EXISTS sakila.inventory CASCADE;
CREATE TABLE sakila.inventory (
  inventory_id SERIAL PRIMARY KEY,
  film_id INT NOT NULL REFERENCES sakila.film(film_id),
  store_id INT NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.staff CASCADE;
CREATE TABLE sakila.staff (
  staff_id SERIAL PRIMARY KEY,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id INT NOT NULL REFERENCES sakila.address(address_id),
  picture BYTEA,
  email VARCHAR(50),
  store_id INT NOT NULL,
  active BOOLEAN DEFAULT TRUE NOT NULL,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40),
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.store CASCADE;
CREATE TABLE sakila.store (
  store_id SERIAL PRIMARY KEY,
  manager_staff_id INT NOT NULL REFERENCES sakila.staff(staff_id),
  address_id INT NOT NULL REFERENCES sakila.address(address_id),
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.customer CASCADE;
CREATE TABLE sakila.customer (
  customer_id SERIAL PRIMARY KEY,
  store_id INT NOT NULL REFERENCES sakila.store(store_id),
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50),
  address_id INT NOT NULL REFERENCES sakila.address(address_id),
  activebool BOOLEAN DEFAULT TRUE NOT NULL,
  create_date DATE DEFAULT CURRENT_DATE NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  active INT
);

DROP TABLE IF EXISTS sakila.rental CASCADE;
CREATE TABLE sakila.rental (
  rental_id SERIAL PRIMARY KEY,
  rental_date TIMESTAMP NOT NULL,
  inventory_id INT NOT NULL REFERENCES sakila.inventory(inventory_id),
  customer_id INT NOT NULL REFERENCES sakila.customer(customer_id),
  return_date TIMESTAMP,
  staff_id INT NOT NULL REFERENCES sakila.staff(staff_id),
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS sakila.payment CASCADE;
CREATE TABLE sakila.payment (
  payment_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES sakila.customer(customer_id),
  staff_id INT NOT NULL REFERENCES sakila.staff(staff_id),
  rental_id INT REFERENCES sakila.rental(rental_id),
  amount NUMERIC(5,2) NOT NULL,
  payment_date TIMESTAMP NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Apply triggers
CREATE TRIGGER actor_last_update BEFORE UPDATE ON sakila.actor FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER country_last_update BEFORE UPDATE ON sakila.country FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER city_last_update BEFORE UPDATE ON sakila.city FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER address_last_update BEFORE UPDATE ON sakila.address FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER category_last_update BEFORE UPDATE ON sakila.category FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER language_last_update BEFORE UPDATE ON sakila.language FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER film_last_update BEFORE UPDATE ON sakila.film FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER staff_last_update BEFORE UPDATE ON sakila.staff FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER store_last_update BEFORE UPDATE ON sakila.store FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER customer_last_update BEFORE UPDATE ON sakila.customer FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER rental_last_update BEFORE UPDATE ON sakila.rental FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
CREATE TRIGGER payment_last_update BEFORE UPDATE ON sakila.payment FOR EACH ROW EXECUTE FUNCTION sakila.set_last_update();
