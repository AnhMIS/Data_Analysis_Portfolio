--Truy vấn số lượng film theo rating
SELECT rating, COUNT(film_id) Num_films
FROM film
GROUP BY film.rating


--Truy vấn độ dài trung bình của film theo rating
SELECT rating, AVG(length) Average_length
FROM film
GROUP BY rating


--Truy vấn tên diễn viên đóng nhiều bộ phim nhất
SELECT TOP 1 WITH TIES actor.first_name + ' ' + actor.last_name Actor, COUNT(film_actor.film_id) Films
FROM actor join film_actor 
	on actor.actor_id = film_actor.actor_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY COUNT(film_actor.film_id) DESC


--Truy vấn thể loại (category) có nhiều bộ phim nhất
SELECT TOP 1 WITH TIES category.name Category, COUNT(film_category.film_id) Films
FROM category join film_category
	on category.category_id = film_category.category_id
GROUP BY category.category_id, category.name
ORDER BY COUNT(film_category.film_id) DESC


--Truy vấn tên quốc gia có nhiều khách hàng nhất
SELECT TOP 1 WITH TIES country.country, COUNT(customer.customer_id) Num_customers
FROM country join city
	on country.country_id = city.country_id
			join address
	on city.city_id = address.city_id
			join customer
	on address.address_id = customer.address_id
GROUP BY country.country_id, country.country
ORDER BY COUNT(customer.customer_id) DESC


--Truy vấn tên bộ phim có nhiều diễn viên tham gia nhất
SELECT TOP 1 WITH TIES film.title, COUNT(film_actor.actor_id) Num_actors
FROM film join film_actor
	on film.film_id = film_actor.film_id
GROUP BY film.film_id, film.title
ORDER BY COUNT(film_actor.actor_id) DESC


--Truy vấn thời gian thuê đĩa trung bình của khách hàng, hiển thị dưới dạng HH:MM
---Trước tiên, cần kiểm tra kiểu dữ liệu 2 cột rental_date và return_date tại bảng rental
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME= 'rental' AND (COLUMN_NAME= 'rental_date' OR COLUMN_NAME= 'return_date')
--------------------------
SELECT CONVERT(nvarchar, AVG(Duration) / 60) + ':' + CONVERT(nvarchar, AVG(Duration) % 60) AVG_rental_duration
FROM (
	SELECT DATEDIFF(minute, rental_date, return_date) Duration
	FROM rental) Rental_duration


-- Truy vấn tên bộ phim được thuê nhiều lần nhất
SELECT TOP 1 WITH TIES film.title, COUNT(rental.rental_id) Num_rentals
FROM film join inventory
	on film.film_id = inventory.film_id
			join rental
	on inventory.inventory_id = rental.inventory_id
GROUP BY film.film_id, film.title
ORDER BY COUNT(rental.rental_id) DESC


--Truy vấn thể loại film có thời gian thuê trung bình lâu nhất, tính theo đơn vị ngày
SELECT TOP 1 WITH TIES Category_name, AVG(Rental_duration) AVG_rental_duration
FROM (
	SELECT category.category_id Category_id, category.name Category_name, DATEDIFF(day, rental.rental_date, rental.return_date) Rental_duration
	FROM category join film_category
		on category.category_id = film_category.category_id
				join film
		on film_category.film_id = film.film_id
				join inventory
		on film.film_id = inventory.film_id
				join rental
		on inventory.inventory_id = rental.inventory_id) Category_rental_duration
GROUP BY Category_id, Category_name
ORDER BY AVG(Rental_duration) DESC


--Truy vấn số lượng film theo special_feature
---Do special_features là một chuỗi các thể loại được liên kết với nhau bằng dấu ',' nên dùng hàm STRING_SPLIT để tách chúng
SELECT Special_feature, COUNT(film_id) Num_films
FROM(
	SELECT film_id, value Special_feature
	FROM film cross apply STRING_SPLIT(special_features, ',')) Features
GROUP BY Special_feature