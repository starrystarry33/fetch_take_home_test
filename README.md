# take_home_test

---

## Overview
* Q1. Reviewing unstructured data and creating a structured relational data model.
* Q2. Writing SQL queries to answer business questions.
* Q3. Identifying and analyzing data quality issues.
* Q4. Communicating findings and technical reasoning in a business-friendly manner.

### Files and Resources

1. **`ERD.png`**  
   The Entity Relationship Diagram showing the relationships between the following tables:
   - `Dim_User`: User-related data.
   - `Fact_Receipt`: Receipts and associated details.
   - `Fact_Receipt_Items`: Individual items within receipts.
   - `Dim_Brands`: Brand information.

2. **`Q2_SQL.sql`**  
   SQL query file addressing the following business question:
   * 1. What are the top 5 brands by receipts scanned for most recent month?
   * 2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
   * 3. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
   * 4. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
   * 5. Which brand has the most spend among users who were created within the past 6 months?
   * 6. Which brand has the most transactions among users who were created within the past 6 months?

4. **`Q3_receipts.ipynb`**  
   Jupyter Notebook for data cleaning, transformation, and exploratory analysis of the `Fact_Receipt` table

5. **`Q3_brands.ipynb`**  
   Jupyter Notebook for analyzing brand-level data from `Dim_Brands` 

6. **`Q3_users.ipynb`**  
   Jupyter Notebook for exploring user data (`Dim_User`)
     
6.**`Communication.pdf`**

---

## Data Modeling

### Tables and Relationships

1. **`Dim_User`**  
   Contains user-related metadata:  
   - **Primary Key:** `user_id`  
   - Fields: `state`, `createdDate`, `lastLogin`, `role`, `active`  

2. **`Fact_Receipt`**  
   Stores receipt-level data for transactions:  
   - **Primary Key:** `receipt_id`  
   - Foreign Key: `user_id` (links to `Dim_User`)  
   - Fields: `totalSpent`, `purchaseDate`, `pointsEarned`, etc.  

3. **`Fact_Receipt_Items`**  
   Details of individual items in a receipt:  
   - **Primary Key:** `item_id`  
   - Foreign Key: `receipt_id` (links to `Fact_Receipt`)  
   - Foreign Key: `brand_id` (links to `Dim_Brands`)  
   - Fields: `item_price`, `final_price`, `quantity`, etc.  

4. **`Dim_Brands`**  
   Metadata about brands:  
   - **Primary Key:** `brand_id`  
   - Fields: `name`, `category`, `brandCode`, etc.  

### Relationships
- **`Dim_User` ↔ `Fact_Receipt`:** Each user can have multiple receipts.
- **`Fact_Receipt` ↔ `Fact_Receipt_Items`:** Each receipt can have multiple items.
- **`Fact_Receipt_Items` ↔ `Dim_Brands`:** Each item is associated with one brand.

---

## Data Quality Analysis

### Key Findings

1. **Dim_User Table:**
   - **Duplicate Rows:** 283 rows were found to be duplicated, leading to potential inaccuracies in user-level analyses.
   - **Missing Values:**
     - `signUpSource`: 48 missing values.
     - `state`: 56 missing values.
     - `last_login`: 62 missing values.
   - **Non-Unique IDs:** 283 rows with duplicate `user_id` values were identified.
   - **Unique Values:**
     - `role`: Contains only two roles: `consumer` and `fetch-staff`.
     - `signUpSource`: Includes `Email`, `Google`, and some missing (`nan`) values.
   - **State Distribution:** The majority of users are from Wisconsin (`WI`: 396), with smaller counts from other states.
   - **Invalid Timestamps:** No invalid timestamps were found where `last_login` is earlier than `created_date`.

2. **Fact_Receipt Table:**
   - **Duplicate Rows:** No duplicate rows were detected.
   - **Missing Values:**
     - Significant columns such as `bonusPointsEarned` (575), `pointsEarned` (510), and `totalSpent` (435) contain missing values, which could lead to incomplete metrics.
     - `finished_date` is missing in 551 rows, potentially affecting receipt completion analysis.
     - `points_awarded_date` is missing in 582 rows.
   - **Distributions:**
     - `totalSpent`:
       - Average: $77.80, Min: $0.00, Max: $4721.95.
     - `bonusPointsEarned`:
       - Average: 238.89 points, Min: 5, Max: 750.
   - **Invalid Data:**
     - No invalid bonus points (`<0`) or total spent values (`<0`) were detected.
   - **Unique Receipt Statuses:** Includes `FINISHED`, `REJECTED`, `FLAGGED`, `SUBMITTED`, and `PENDING`.

3. **Fact_Receipt_Items Table:**
   - **Duplicate Rows:** No duplicate rows were detected.
   - **Missing Values:**
     - `category`: 155 missing values.
     - `categoryCode`: 650 missing values.
     - `topBrand`: 612 missing values.
   - **Unique Values:**
     - Categories: Includes distinct categories like `Baking`, `Beverages`, `Candy & Sweets`, and more.
     - Category Codes: Includes distinct codes such as `BAKING`, `BEVERAGES`, `CANDY_AND_SWEETS`, and more.
   - **Missing Barcodes:** No missing barcodes were detected.

### Observations and Recommendations

1. **Missing Data:**
   - Missing values in critical columns like `bonusPointsEarned`, `totalSpent`, and `categoryCode` can lead to incomplete analyses. It is recommended to:
     - Investigate why these values are missing (e.g., system errors, incomplete data entry).
     - Implement data validation checks at the ETL stage to ensure completeness.

2. **Duplicate Data:**
   - The `Dim_User` table contains 283 duplicate rows with non-unique IDs. Recommendations:
     - Deduplicate the data by enforcing unique constraints on `user_id`.
     - Ensure proper logging and handling of duplicate user entries during ingestion.

3. **Inconsistent Categories:**
   - The `Fact_Receipt_Items` table has missing or inconsistent `category` and `categoryCode` values. Recommendations:
     - Standardize these columns by mapping missing or incorrect values to predefined categories.
     - Maintain a reference table for valid categories and enforce checks during data loading.

4. **Invalid Data:**
   - While no invalid data (e.g., negative values for `bonusPointsEarned` or `totalSpent`) was detected, this should be monitored continuously.

5. **Scaling Concerns:**
   - High volumes of incomplete or duplicated data can impact query performance. Recommended actions:
     - Partition tables like `Fact_Receipt` and `Fact_Receipt_Items` by time (e.g., monthly) to optimize performance.
     - Add indexes on frequently queried columns like `user_id`, `receipt_id`, and `brand_id`.

By addressing these data quality issues, the overall reliability, and efficiency of the data model can be significantly improved.

