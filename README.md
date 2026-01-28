# Maven Fuzzy Factory – E-Commerce Analytics Project

## 📌 Project Overview
This project analyzes e-commerce data for **Maven Fuzzy Factory**, an online retailer selling teddy bears.
Using **MySQL**, raw website session, order, and revenue data were cleaned, validated, and analyzed to
evaluate marketing performance, website conversion efficiency, and revenue trends.

## 🎯 Business Questions
1. What is the trend in website sessions and order volume?
2. What is the session-to-order conversion rate, and how has it trended?
3. Which marketing channels perform best?
4. How have revenue per order and revenue per session evolved over time?

## 🛠 Tools Used
- MySQL
- SQL
- CSV datasets
- ReportLab (for reporting)

## 🧹 Data Preparation
- Raw tables preserved and clean tables created
- NULL, duplicate, and referential integrity checks performed
- Refunds exceeding item prices flagged (not removed)
- Marketing UTM fields identified as binary indicators after ingestion

## 📊 Key Insights
- Website traffic and orders increased steadily over time
- Conversion rate remained relatively stable; growth was traffic-driven
- Paid / Tagged traffic monetized more efficiently than Organic Search
- Revenue per session improved due to higher AOV and traffic quality

## 📁 Repository Structure
- `/data` → raw CSV files
- `/sql` → all SQL scripts used in analysis
- `/reports` → full project reports in PDF format

## 📄 Reports
See the `/reports` folder for complete, step-by-step analysis with SQL queries and outputs.

## 🚀 Next Improvements
- Reload data with proper UTM parsing for granular attribution
- Build Tableau / Power BI dashboards
- Add forecasting and cohort analysis

