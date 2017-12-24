-- 1a. Display the first and last names of all actors from the table `actor`. 
SELECT first_name,' ',last_name
FROM actor;

--1b. Display the first and last name of each actor in a single column in upper case letters. 
--Name the column `Actor Name`. 
SELECT CONCAT(first_name, ' ' ,last_name) AS Actor_name
FROM actor;

--2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'JOE';

--2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%li%';

--2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

--3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(50);

-- 3b. You realize that some of these actors have tremendously long last names.
-- Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor
DROP COLUMN middle_name;
ALTER TABLE actor
ADD middle_name VARBINARY(500);

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor
DROP COLUMN middle_name;

--4b. List last names of actors and the number of actors who have that last name, 
--but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) 
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >1;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as
-- `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher.
-- Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

--4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
--It turns out that `GROUCHO` was the correct name after all! 
--In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
-- Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be
-- with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`,
-- HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

--5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE address (
address_id  SMALLINT(5) NOT NULL ,
address  VARCHAR(50) NOT NULL,
address VARCHAR(50) ,
district VARCHAR(20) ,
city_id SMALLINT(5),
postal_code VARCHAR(10),
phone VARCHAR(20),
location GEOMETRY,
last_update TIMESTAMP,
INDEX Indexes(address_id, city_id, location),
FOREIGN KEY (city_id) REFERENCES city(city_id) 
);

--6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
--Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

--6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
--Use tables `staff` and `payment`. 
SELECT staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY payment.staff_id;

--6c. List each film and the number of actors who are listed for that film. 
--Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id)
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id;

--6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.inventory_id)
FROM inventory
INNER JOIN film ON film.film_id = inventory.film_id
WHERE film.title =  'Hunchback Impossible'
GROUP BY film.film_id;

--6e. Using the tables `payment` and `customer` and the `JOIN` command, 
--list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount)
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

--7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
--As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
--Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT film.title
FROM film
INNER JOIN language ON film.language_id = language.language_id
WHERE language.name = 'English' AND 
(
	film.title LIKE 'K%' OR
    film.title LIKE 'Q%' 
);

--7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id IN
	(
	SELECT film_actor.actor_id
	FROM film_actor
	WHERE film_actor.film_id = 
		(
		SELECT film.film_id
		FROM film
		WHERE film.title = 'Alone Trip'
		)
	);

--7c. You want to run an email marketing campaign in Canada,
-- for which you will need the names and email addresses of all Canadian customers. 
--Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM customer
INNER JOIN address ON customer.address_id IN
(
	SELECT 	address.address_id
	FROM address
	INNER JOIN city ON address.city_id IN
    (
		SELECT city.city_id
		FROM city
		INNER JOIN country ON city.country_id = country.country_id
        WHERE country.country = 'Canada'
	)
);

--7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
--Identify all movies categorized as famiy films.
SELECT film.title
FROM film
WHERE film.film_id IN 
	(
	SELECT film_category.film_id
	FROM film_category
	WHERE film_category.category_id =
		(
		SELECT category.category_id
		FROM category
		WHERE category.name = 'Family'
		)
	);

--7e. Display the most frequently rented movies in descending order.
-- NEED TO CHECK THIS
SELECT film.title
FROM film
WHERE film.film_id IN
(
	SELECT inventory.film_id
    FROM inventory
    WHERE inventory.inventory_id IN
    (
		SELECT rental.inventory_id
        FROM rental
        GROUP BY rental.inventory_id
        ORDER BY COUNT(rental.inventory_id) DESC
	)
	ORDER BY inventory.inventory_id
);

--7f. Write a query to display how much business, in dollars, each store brought in.
SELECT T1.store_id,SUM(payment.amount)
FROM
	(
	SELECT store.store_id,customer.customer_id
	FROM store
	INNER JOIN customer ON store.store_id = customer.store_id
	) AS T1
INNER JOIN payment ON T1.store_id = payment.customer_id
GROUP BY T1.store_id;

--7g. Write a query to display for each store its store ID, city, and country.
SELECT T2.store_id,T2.city, country.country
FROM
	(
	SELECT T1.store_id,T1.city_id, city.city, city.country_id
	FROM 
		(
		SELECT store.store_id,address.city_id
		FROM store
		INNER JOIN address ON store.address_id = address.address_id
		) AS T1
	INNER JOIN city ON T1.city_id = city.city_id
	) AS T2
INNER JOIN country ON T2.country_id = country.country_id;

--7h. List the top five genres in gross revenue in descending order. 
--(**Hint**: you may need to use the following tables: category, film_category,
--inventory, payment, and rental.)
SELECT category.name, T3.revenue
FROM 
	(
	SELECT film_category.category_id, SUM(T2.amt) as revenue
	FROM 
		(
		SELECT inventory.film_id, T1.amt
		FROM 
			(
			SELECT rental.inventory_id, SUM(payment.amount) AS amt
			FROM payment
			INNER JOIN rental ON rental.rental_id = payment.rental_id
			GROUP BY payment.rental_id
			) AS T1
		INNER JOIN inventory ON inventory.inventory_id = T1.inventory_id
		) AS T2
	INNER JOIN film_category ON film_category.film_id = T2.film_id
	GROUP BY film_category.category_id
	) AS T3
INNER JOIN category ON category.category_id = T3.category_id
ORDER BY T3.revenue DESC
LIMIT 5;

--8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
--Use the solution from the problem above to create a view. 
CREATE VIEW Top_5_genre AS
(
	SELECT category.name, T3.revenue
	FROM 
		(
		SELECT film_category.category_id, SUM(T2.amt) as revenue
		FROM 
			(
			SELECT inventory.film_id, T1.amt
			FROM 
				(
				SELECT rental.inventory_id, SUM(payment.amount) AS amt
				FROM payment
				INNER JOIN rental ON rental.rental_id = payment.rental_id
				GROUP BY payment.rental_id
				) AS T1
			INNER JOIN inventory ON inventory.inventory_id = T1.inventory_id
			) AS T2
		INNER JOIN film_category ON film_category.film_id = T2.film_id
		GROUP BY film_category.category_id
		) AS T3
	INNER JOIN category ON category.category_id = T3.category_id
	ORDER BY T3.revenue DESC
	LIMIT 5
);

--8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5_genre;

--8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_5_genre;