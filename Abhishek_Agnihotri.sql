/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.

SELECT customer_id,
		CONCAT((CASE
					WHEN customer_gender = 'M' THEN 'Mr. '
					WHEN customer_gender = 'F' THEN 'Ms. '
				END),
				UPPER(customer_fname),
				' ',
				UPPER(customer_Lname)) AS customer_full_name,
		customer_email,
		YEAR(customer_creation_date) AS customer_creation_year,
		CASE
			WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'A'
			WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'B'
			WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2011 THEN 'C'
		END AS customer_category
FROM online_customer;


/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.

SELECT 	product_id,
		product_desc,
		product_quantity_avail,
		product_price,
		product_quantity_avail * product_price AS inventory_values,
		product_price * (CASE
							 WHEN product_price > 20000 THEN (0.80)
							 WHEN product_price > 10000 THEN (0.85)
							 WHEN product_price <= 10000 THEN (0.90)
						 END) AS new_price
FROM product
WHERE product_id NOT IN (SELECT product_id FROM order_items)
ORDER BY inventory_values DESC; 


/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.

SELECT product_class_code,
	   product_class_desc,
       COUNT(DISTINCT product_id) as count_product_type,
       SUM(product_price * product_quantity_avail) AS inventory_value
FROM product
JOIN product_class 
USING (product_class_code)
GROUP BY product_class_code
HAVING inventory_value > 100000
ORDER BY inventory_value DESC;


/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.

SELECT c.customer_id,
       CONCAT(c.customer_fname,
              ' ',
              c.customer_lname) AS customer_full_name,
       c.customer_email,
       c.customer_phone,
       a.country as customer_country
FROM ONLINE_CUSTOMER c
JOIN ADDRESS a 
USING(address_id)
WHERE c.customer_id IN (SELECT h.customer_id 
						 FROM ORDER_HEADER h
						 WHERE h.order_status = 'Cancelled'
						 GROUP BY h.customer_id
						 HAVING COUNT(*) = (SELECT COUNT(*)
										    FROM ORDER_HEADER
                                            WHERE customer_id = h.customer_id));



/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  

SELECT shipper_name, 
	   city, 
       COUNT(DISTINCT(customer_id)) as num_of_customer_catered,
       COUNT(DISTINCT(order_id)) as num_of_consignment_delivered
FROM order_header 
LEFT JOIN shipper 
USING (shipper_id)
LEFT JOIN online_customer 
USING (customer_id)
LEFT JOIN address 
USING (address_id)
WHERE shipper_name = 'DHL'
GROUP BY city;


/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.


SELECT p.product_id,
       p.product_desc,
       p.product_quantity_avail,
       SUM(oi.product_quantity) AS quantity_sold,
       CASE
			WHEN pc.product_class_desc IN ('Electronics' , 'Computer') THEN
            CASE
                WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < SUM(oi.product_quantity) * 0.1 THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < SUM(oi.product_quantity) * 0.5 THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
		   WHEN pc.product_class_desc IN ('Mobiles' , 'Watches') THEN
		   CASE
                WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < SUM(oi.product_quantity) * 0.2 THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < SUM(oi.product_quantity) * 0.6 THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
		ELSE CASE
				WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
				WHEN p.product_quantity_avail < SUM(oi.product_quantity) * 0.3 THEN 'Low inventory, need to add inventory'
				WHEN p.product_quantity_avail < SUM(oi.product_quantity) * 0.7 THEN 'Medium inventory, need to add some inventory'
				ELSE 'Sufficient inventory'
            END
	    END AS inventory_status
FROM PRODUCT p
JOIN PRODUCT_CLASS pc 
ON p.product_class_code = pc.product_class_code
LEFT JOIN ORDER_ITEMS oi 
ON p.product_id = oi.product_id
GROUP BY p.product_id , p.product_desc , p.product_quantity_avail , pc.product_class_desc;

/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.


SELECT order_id,
       SUM(len * width * height * PRODUCT_QUANTITY) AS volume_of_the_biggest_order
FROM order_items
LEFT JOIN product p 
USING (product_id)
GROUP BY 1
HAVING volume_of_the_biggest_order < (SELECT (len * width * height) AS volume
									  FROM carton
									  WHERE carton_id = 10)
ORDER BY 2 DESC
LIMIT 1; 

/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.
SELECT  c.customer_id,
		CONCAT(c.customer_fname, ' ', c.customer_lname) AS customer_name,
		SUM(s.product_quantity) AS total_quantity,
		SUM(s.product_quantity * p.product_price) AS total_value
FROM online_customer c
INNER JOIN order_header o 
ON c.customer_id = o.customer_id
INNER JOIN order_items s 
ON o.order_id = s.order_id
INNER JOIN product p 
ON s.product_id = p.product_id
WHERE c.customer_lname LIKE 'G%' AND o.payment_mode = 'Cash'
GROUP BY c.customer_id
HAVING COUNT(DISTINCT o.order_id) >= 1;



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
Expected 5 rows in final output
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.


SELECT p.product_id,
       p.product_desc,
       SUM(oi.product_quantity) AS total_quantity
FROM order_items oi
JOIN product p 
ON oi.product_id = p.product_id
JOIN order_header oh
ON oi.order_id = oh.order_id
JOIN online_customer oc 
ON oh.customer_id = oc.customer_id
JOIN address a 
ON oc.address_id = a.address_id
WHERE oi.order_id IN (SELECT oi2.order_id
					  FROM order_items oi2
					  WHERE oi2.product_id = 201) AND a.city NOT IN ('Bangalore' , 'New Delhi') AND oi.product_id != 201 AND oh.order_status = 'shipped'
GROUP BY p.product_id , p.product_desc
ORDER BY total_quantity DESC;



/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */


## Answer 10.

SELECT order_id,
       customer_id,
	   CONCAT(customer_fname, ' ', customer_lname) AS full_name,
       SUM(product_quantity) AS total_quantity
FROM online_customer
INNER JOIN address 
USING (address_id)
INNER JOIN order_header 
USING (customer_id) 
INNER JOIN order_items 
USING (order_id)
WHERE pincode NOT LIKE '5%' AND order_status = 'shipped' AND order_id % 2 = 0
GROUP BY order_id , customer_id;


