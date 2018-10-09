USE sakila;

/*SHOW FIELDS FROM sakila.actor;
	 actor_id, first_name, last_name, last_update */

SELECT * FROM sakila.actor;

/*SELECT COUNT(*) FROM sakila.actor;  
	200 rows*/


#1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM sakila.actor;

#1b. Display the first and last name of each actor in a single column in 
#upper case letters. Name the column Actor Name.
SELECT 
    concat( upper(first_name),' ', upper(last_name)) AS ActorName
FROM sakila.actor;

#2a. You need to find the ID number, first name, and last name of an actor, 
#of whom you know only the first name, "Joe."What is one query would you use to obtain this information?
SELECT actor_id,first_name, last_name 
FROM sakila.actor 
WHERE first_name="Joe";

#2b. Find all actors whose last name contain the letters GEN:
SELECT last_name 
FROM sakila.actor 
WHERE last_name LIKE '%GEN%';


#2c. Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order:
SELECT last_name,first_name 
FROM sakila.actor 
WHERE last_name LIKE '%LI%'
ORDER BY last_name , first_name;

#2d. Using IN, display the country_id and 
#country columns of the following countries: Afghanistan, Bangladesh, and China:
#SELECT * FROM sakila.country;
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China'); /*1,12, 23*/

#3a. You want to keep a description of each actor. You don't think you will be performing queries 
#on a description, so create a column in the table actor named description and use the 
#data type BLOB (Make sure to research the type BLOB, as the difference between it and 
#VARCHAR are significant).

-- Before --
#SELECT * FROM sakila.actor;

ALTER TABLE sakila.actor 
ADD COLUMN description BLOB;

-- After --
#SELECT * FROM sakila.actor;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
#Delete the description column.

ALTER TABLE sakila.actor 
DROP COLUMN description ;

-- After --
#SELECT * FROM sakila.actor;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) 
FROM sakila.actor
GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for 
#names that are shared by at least two actors.
SELECT last_name, COUNT(*) 
FROM sakila.actor
GROUP BY last_name
HAVING COUNT(*) >= 2;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#Write a query to fix the record.
-- Before --
/*SELECT first_name, last_name 
FROM sakila.actor 
WHERE last_name="WILLIAMS";*/

UPDATE sakila.actor
SET first_name="HARPO"
WHERE first_name="GROUCHO" AND last_name="WILLIAMS";

-- After --
/*SELECT first_name, last_name 
FROM sakila.actor 
WHERE last_name="WILLIAMS";*/

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was 
#the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it 
#to GROUCHO.

-- Turn off safe updates
SET SQL_SAFE_UPDATES = 0;

UPDATE sakila.actor
SET first_name="GROUCHO"
WHERE first_name="HARPO";

-- After --
/*SELECT first_name, last_name 
FROM sakila.actor 
WHERE last_name="WILLIAMS";*/

--  Turn safe updates on
SET SQL_SAFE_UPDATES = 1;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW FIELDS FROM sakila.address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
#Use the tables staff and address:
-- SHOW FIELDS FROM sakila.staff; --
SELECT s.first_name, s.last_name, a.address
FROM sakila.staff s
INNER JOIN sakila.address a
ON (s.address_id = a.address_id);

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.
#SHOW FIELDS FROM sakila.payment; 
/*SELECT * FROM sakila.payment 
where Month(payment_date)=8 AND Year(payment_date)=2005;*/
-- payment_date=2005-08-15 00:54:12 --

SELECT s.staff_id, 
	SUM(p.amount) AS 'Total Payment by Staff'
FROM sakila.staff s
INNER JOIN sakila.payment p ON (s.staff_id = p.staff_id)
WHERE Month(payment_date)=8 AND Year(payment_date)=2005
GROUP BY p.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
#Use inner join.
/*SHOW FIELDS FROM sakila.film_actor; 
SHOW FIELDS FROM sakila.film; */
SELECT f.title, count(fa.actor_id) as ActorCount
FROM sakila.film_actor fa
INNER JOIN sakila.film f
ON (fa.film_id = f.film_id)
GROUP BY f.film_id;

-- Validate
/*SELECT f.title, fa.actor_id
FROM film_actor fa
INNER JOIN film f
ON (fa.film_id = f.film_id)
WHERE f.title="ACADEMY DINOSAUR";*/

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(film_id) AS 'Number of copies'
FROM sakila.film
WHERE title="HUNCHBACK IMPOSSIBLE";  /*1*/

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each 
#customer. List the customers alphabetically by last name:  (Refer figure)
-- SHOW FIELDS FROM sakila.customer ; --
SELECT c.customer_id, c.first_name, c.last_name,
	SUM(p.amount) AS 'Total Payment by Customer'
FROM sakila.customer c
INNER JOIN sakila.payment p ON (c.customer_id = p.customer_id)
GROUP BY p.customer_id
ORDER BY c.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- SELECT * FROM sakila.language;-- 
SELECT title  
FROM sakila.film
WHERE title LIKE 'K%' OR title LIKE 'Q%'  AND language_id IN
(
SELECT language_id
FROM sakila.language
WHERE  language_id IN
(
SELECT language_id
FROM sakila.film
WHERE name="English"
)
)
;

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name  
FROM sakila.actor
WHERE  actor_id IN
(
SELECT actor_id
FROM sakila.film_actor
WHERE  film_id IN
(
SELECT film_id
FROM sakila.film_actor
WHERE  film_id IN
(
SELECT film_id
FROM sakila.film
WHERE title="Alone Trip"
)
)
)
;

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
#email addresses of all Canadian customers. Use joins to retrieve this information.
/*SELECT * FROM sakila.country;
SELECT * FROM sakila.address;*/

SELECT first_name, last_name, email  
FROM sakila.customer
WHERE  address_id IN
(
SELECT address_id
FROM sakila.address
WHERE  city_id IN
(
SELECT city_id
FROM sakila.city
WHERE  country_id IN
(
SELECT country_id
FROM sakila.country
WHERE country="Canada"
)
)
)
;


#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
/*SELECT * FROM sakila.film;
SELECT * FROM sakila.category;*/

SELECT title
FROM sakila.film
WHERE  film_id IN
(
SELECT film_id
FROM sakila.film_category
WHERE  category_id IN
(
SELECT category_id
FROM sakila.category
WHERE name="Family"
)
)
;


#7e. Display the most frequently rented movies in descending order.

SELECT title
FROM sakila.film
WHERE  film_id IN
(
SELECT film_id
FROM sakila.inventory
WHERE  inventory_id IN
(
SELECT inventory_id
FROM sakila.rental
WHERE  rental_id IN
(SELECT  rental_id
FROM sakila.rental
GROUP BY rental_id
HAVING MAX(rental_id)
)
)
)
;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff_id, sum(amount)
FROM sakila.payment
GROUP BY staff_id
;


#7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city, country
FROM sakila.store s
INNER JOIN sakila.customer c ON s.store_id = c.store_id
INNER JOIN sakila.staff st ON s.store_id = st.store_id
INNER JOIN sakila.address a ON c.address_id = a.address_id
INNER JOIN sakila.city ct ON a.city_id = ct.city_id
INNER JOIN sakila.country ctr ON ct.country_id = ctr.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
/**/
SELECT name, SUM(p.amount)
FROM sakila.category c
INNER JOIN sakila.film_category fc ON c.category_id = fc.category_id
INNER JOIN sakila.inventory i ON i.film_id = fc.film_id
INNER JOIN sakila.rental r ON r.inventory_id = i.inventory_id
INNER JOIN sakila.payment p ON p.rental_id = r.rental_id
GROUP BY name
LIMIT 5;


#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
#by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT name, SUM(p.amount)
FROM sakila.category c
INNER JOIN sakila.film_category fc ON c.category_id = fc.category_id
INNER JOIN sakila.inventory i ON i.film_id = fc.film_id
INNER JOIN sakila.rental r ON r.inventory_id = i.inventory_id
INNER JOIN sakila.payment p ON p.rental_id = r.rental_id
GROUP BY name
LIMIT 5;


#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
#Appendix: List of Tables in the Sakila DB
#A schema is also available as sakila_schema.svg. Open it with a browser to view.
DROP VIEW top_five_genres;





