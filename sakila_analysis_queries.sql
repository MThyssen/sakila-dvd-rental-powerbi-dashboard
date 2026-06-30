-- 0. Sanity Check: Row Count

SELECT COUNT(*) FROM rental;

-- 1. Revenue by Film Category

SELECT
	c.name AS Category,
	SUM(p.amount) AS TotalRevenue,
	COUNT(p.payment_id) AS NumberOfRentals
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY TotalRevenue DESC;

-- 2. Rental Rate Distribution

SELECT DISTINCT rental_rate
FROM film
ORDER BY rental_rate;


-- 3. What Drives Rental Pricing?

SELECT
	rental_rate,
	COUNT(*) AS NumberOfFilms,
	ROUND(AVG(length),1) AS AvgLengthMinutes,
	ROUND(AVG(replacement_cost), 2) AS AvgReplacementCost,
	GROUP_CONCAT(DISTINCT rating) AS RatingsPresent
FROM film
GROUP BY rental_rate
ORDER BY rental_rate;

-- 4. Most Efficiently Utilized Films (Highest Rentals per Copy)

SELECT
    f.title AS Film,
    c.name AS Category,
    COUNT(DISTINCT i.inventory_id) AS TotalCopies,
    COUNT(r.rental_id) AS TotalRentals,
    ROUND(COUNT(r.rental_id) * 1.0 / COUNT(DISTINCT i.inventory_id), 1) AS RentalsPerCopy
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY COUNT(r.rental_id) * 1.0 / COUNT(DISTINCT i.inventory_id) DESC
LIMIT 10;

-- 5. Least Efficiently Utilized Films (Lowest Rentals per Copy)

SELECT
    f.title AS Film,
    c.name AS Category,
    COUNT(DISTINCT i.inventory_id) AS TotalCopies,
    COUNT(r.rental_id) AS TotalRentals,
    ROUND(COUNT(r.rental_id) * 1.0 / COUNT(DISTINCT i.inventory_id), 1) AS RentalsPerCopy
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY RentalsPerCopy ASC
LIMIT 10;

-- 6. Top 10 Customers by Total Spend

SELECT
    c.first_name || ' ' || c.last_name AS CustomerName,
    co.country AS Country,
    COUNT(r.rental_id) AS TotalRentals,
    SUM(p.amount) AS TotalSpent,
    ROUND(SUM(p.amount) / COUNT(r.rental_id), 2) AS AvgSpentPerRental
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
JOIN rental r ON c.customer_id = r.customer_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id
ORDER BY TotalSpent DESC
LIMIT 10;