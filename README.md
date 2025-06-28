# 🏨 SQL Hotel Booking Analysis Project

This project presents an end-to-end **SQL-based exploratory analysis** on a hypothetical **Hotel Booking Database**.  
It includes both **raw dataset files (Excel format)** and **SQL query scripts** answering real-world business questions.

---

## 📌 Project Overview:

The goal is to analyze hotel booking trends, customer behavior, revenue patterns, and hotel occupancy rates using SQL.  
This project is ideal for practicing **SQL querying**, **data analysis**, **aggregation**, **window functions**, and **CTE usage**.

---

## 📂 Folder Structure:
Hotel_Booking_SQL_Project/
├── Dataset/
│ ├── hotel_bookings.xlsx
│ ├── customers.xlsx
│ ├── hotels.xlsx
│ └── cities.xlsx
├── Hotel_Booking_Project.sql
└── README.md

---

## 🛠️ Datasets Used:

| Table Name        | Description                           |
|-------------------|---------------------------------------|
| hotel_bookings    | Customer booking transactions         |
| customers         | Customer details (ID, Gender, City, DOB) |
| hotels            | Hotel info (ID, City, Capacity)       |
| cities            | City & State mapping                  |

---

## ✅ Business Questions Solved (SQL Queries):

1. **Top customers booking most in their home city**
2. **Percentage revenue and bookings from female customers per hotel**
3. **Hotel-wise bookings from customers of different states**
4. **Hotel dates with maximum occupancy**
5. **Customers who booked in at least 3 different states**
6. **Hotel occupancy rate per month**
7. **Dates with 100% full occupancy for each hotel**
8. **Top booking channel (per hotel per month) by sales**
9. **Percent share of bookings by each booking channel**
10. **Revenue comparison: Millennials vs Gen Z (per hotel)**
11. **Average stay duration per hotel**
12. **Average lead time (days customers booked in advance)**
13. **Customers who never booked any hotel**
14. **Customers who stayed in at least 3 different hotels in the same month**

---

## ✅ Key SQL Concepts Used:

- **Joins (INNER, LEFT)**
- **Common Table Expressions (CTEs)**
- **Window Functions (ROW_NUMBER, RANK)**
- **Aggregate Functions (COUNT, SUM, AVG)**
- **Group By and Having Clauses**
- **Date Functions (DATEDIFF, DATEADD, FORMAT)**

---

## ✅ Tools Used:

- **Microsoft SQL Server**
- **SQL Server Management Studio (SSMS)**
- **Excel (for raw datasets)**

---

## ✅ Author:

**Sai Sri Raj Rangu**  
📍 Master’s in Information Systems | Trine University  
📧 GitHub: [rangusaisiraj](https://github.com/rangusaisiraj)  

---

## ✅ How to Use This Project:

1. Download the datasets from the `/Dataset` folder.
2. Restore or load them into your SQL Server as sample tables.
3. Run the queries from `Hotel_Booking_Project.sql` in SSMS.
4. Explore and modify queries for your own learning.

---

## ✅ License:

This project is for learning and academic showcase purposes only.

---

