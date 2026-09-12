"""
data_generation.py
-------------------
Generates a realistic synthetic e-commerce transactional dataset for the
E-Commerce Sales & Customer Analytics project.

The dataset intentionally contains realistic relationships between sales,
quantity, discount, profit, customers, products, regions and dates, AND
intentionally injects realistic data-quality issues (missing values,
duplicates, inconsistent formatting, invalid values, date inconsistencies)
so that the downstream data-cleaning notebook demonstrates genuine analytical
work.

Run:
    python src/data_generation.py

Output:
    data/raw/ecommerce_raw.csv
"""

import numpy as np
import pandas as pd
from faker import Faker
import random
import os

# ----------------------------------------------------------------------
# Reproducibility
# ----------------------------------------------------------------------
SEED = 42
random.seed(SEED)
np.random.seed(SEED)
fake = Faker()
Faker.seed(SEED)

N_ORDERS = 42000          # number of order-line records to generate
N_CUSTOMERS = 4200         # unique customers
OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "raw", "ecommerce_raw.csv")

# ----------------------------------------------------------------------
# Reference / dimension data
# ----------------------------------------------------------------------
CATEGORY_SUBCATEGORY = {
    "Electronics": ["Mobiles", "Laptops", "Headphones", "Cameras", "Accessories"],
    "Furniture": ["Chairs", "Tables", "Bookcases", "Storage", "Furnishings"],
    "Clothing": ["Men", "Women", "Kids", "Footwear", "Winterwear"],
    "Office Supplies": ["Paper", "Binders", "Art", "Supplies", "Labels"],
    "Home & Kitchen": ["Cookware", "Appliances", "Decor", "Storage", "Lighting"],
    "Sports": ["Fitness", "Outdoor", "Team Sports", "Cycling", "Apparel"],
}

# Base unit price ranges per category (used to keep Sales/Profit realistic)
CATEGORY_PRICE_RANGE = {
    "Electronics": (1500, 60000),
    "Furniture": (1200, 35000),
    "Clothing": (300, 4000),
    "Office Supplies": (50, 2500),
    "Home & Kitchen": (400, 12000),
    "Sports": (300, 8000),
}

# Category-level baseline profit margin (before discount effects)
CATEGORY_BASE_MARGIN = {
    "Electronics": 0.14,
    "Furniture": 0.10,
    "Clothing": 0.22,
    "Office Supplies": 0.18,
    "Home & Kitchen": 0.16,
    "Sports": 0.19,
}

REGION_STATE_CITY = {
    "North": {
        "Delhi": ["New Delhi", "Dwarka", "Rohini"],
        "Punjab": ["Ludhiana", "Amritsar", "Chandigarh"],
        "Uttar Pradesh": ["Lucknow", "Noida", "Kanpur"],
    },
    "South": {
        "Karnataka": ["Bengaluru", "Mysuru", "Mangaluru"],
        "Tamil Nadu": ["Chennai", "Coimbatore", "Madurai"],
        "Telangana": ["Hyderabad", "Warangal", "Nizamabad"],
    },
    "West": {
        "Maharashtra": ["Mumbai", "Pune", "Nagpur"],
        "Gujarat": ["Ahmedabad", "Surat", "Vadodara"],
        "Rajasthan": ["Jaipur", "Udaipur", "Jodhpur"],
    },
    "East": {
        "West Bengal": ["Kolkata", "Howrah", "Siliguri"],
        "Odisha": ["Bhubaneswar", "Cuttack", "Rourkela"],
        "Bihar": ["Patna", "Gaya", "Bhagalpur"],
    },
}

PAYMENT_MODES = ["Credit Card", "Debit Card", "UPI", "Net Banking", "Cash on Delivery", "Wallet"]
PAYMENT_WEIGHTS = [0.20, 0.15, 0.30, 0.10, 0.15, 0.10]

SHIPPING_MODES = ["Standard", "Express", "Same Day", "Economy"]
SHIPPING_WEIGHTS = [0.55, 0.25, 0.08, 0.12]

# Seasonal monthly demand multipliers (festive/sale season boost in India: Oct-Nov, Jan)
MONTH_DEMAND_MULTIPLIER = {
    1: 1.15, 2: 0.90, 3: 0.95, 4: 0.90, 5: 0.95, 6: 0.90,
    7: 0.90, 8: 0.95, 9: 1.05, 10: 1.35, 11: 1.40, 12: 1.10,
}

DATE_START = pd.Timestamp("2022-01-01")
DATE_END = pd.Timestamp("2023-12-31")


def weighted_month_date(year_choices):
    """Pick a random date biased by seasonal demand multipliers."""
    year = random.choice(year_choices)
    months = list(MONTH_DEMAND_MULTIPLIER.keys())
    weights = [MONTH_DEMAND_MULTIPLIER[m] for m in months]
    month = random.choices(months, weights=weights, k=1)[0]
    day = random.randint(1, 28)
    return pd.Timestamp(year=year, month=month, day=day)


def build_customers(n):
    customers = []
    for i in range(1, n + 1):
        customers.append({
            "Customer_ID": f"CUST-{i:05d}",
            "Customer_Name": fake.name(),
            # customers tend to cluster in a region (loyalty to local warehouse)
            "Home_Region": random.choice(list(REGION_STATE_CITY.keys())),
        })
    return pd.DataFrame(customers)


def build_products():
    products = []
    pid = 1
    for cat, subs in CATEGORY_SUBCATEGORY.items():
        for sub in subs:
            # multiple products per sub-category
            for _ in range(random.randint(8, 14)):
                low, high = CATEGORY_PRICE_RANGE[cat]
                base_price = round(np.random.uniform(low, high), 2)
                products.append({
                    "Product_ID": f"PROD-{pid:05d}",
                    "Product_Name": f"{sub} {fake.word().capitalize()} {random.choice(['Pro','Plus','Lite','Max','Classic','Elite'])}",
                    "Category": cat,
                    "Sub_Category": sub,
                    "Base_Price": base_price,
                })
                pid += 1
    return pd.DataFrame(products)


def generate_orders(customers_df, products_df, n_orders):
    records = []
    customer_ids = customers_df["Customer_ID"].tolist()
    customer_region_map = dict(zip(customers_df["Customer_ID"], customers_df["Home_Region"]))
    customer_name_map = dict(zip(customers_df["Customer_ID"], customers_df["Customer_Name"]))

    # Give customers unequal purchase probability (Pareto-like: some customers buy a lot more)
    cust_weights = np.random.pareto(a=2.0, size=len(customer_ids)) + 0.1

    for i in range(1, n_orders + 1):
        cust_idx = random.choices(range(len(customer_ids)), weights=cust_weights, k=1)[0]
        cust_id = customer_ids[cust_idx]
        home_region = customer_region_map[cust_id]

        prod = products_df.sample(1).iloc[0]
        category = prod["Category"]
        base_price = prod["Base_Price"]

        order_date = weighted_month_date([2022, 2023])

        quantity = np.random.choice([1, 2, 3, 4, 5], p=[0.45, 0.25, 0.15, 0.10, 0.05])

        # Discount tends to be higher during festive months (Oct/Nov) and varies by category
        festive = order_date.month in (10, 11)
        base_discount = np.random.choice(
            [0.0, 0.05, 0.10, 0.15, 0.20, 0.30, 0.40],
            p=[0.30, 0.20, 0.18, 0.14, 0.10, 0.05, 0.03]
        )
        if festive:
            base_discount = min(base_discount + np.random.choice([0.0, 0.05, 0.10]), 0.6)

        gross_sales = round(base_price * quantity, 2)
        sales = round(gross_sales * (1 - base_discount), 2)

        base_margin = CATEGORY_BASE_MARGIN[category]
        # Higher discount erodes margin more than proportionally (realistic effect)
        effective_margin = base_margin - (base_discount * 0.9)
        # small random noise in margin
        effective_margin += np.random.normal(0, 0.03)
        profit = round(sales * effective_margin, 2)

        # 90% of the time the customer buys from a location near their home region
        if random.random() < 0.85:
            region = home_region
        else:
            region = random.choice(list(REGION_STATE_CITY.keys()))
        state = random.choice(list(REGION_STATE_CITY[region].keys()))
        city = random.choice(REGION_STATE_CITY[region][state])

        payment_mode = random.choices(PAYMENT_MODES, weights=PAYMENT_WEIGHTS, k=1)[0]
        shipping_mode = random.choices(SHIPPING_MODES, weights=SHIPPING_WEIGHTS, k=1)[0]

        records.append({
            "Order_ID": f"ORD-{i:06d}",
            "Order_Date": order_date,
            "Customer_ID": cust_id,
            "Customer_Name": customer_name_map[cust_id],
            "Product_ID": prod["Product_ID"],
            "Product_Name": prod["Product_Name"],
            "Category": category,
            "Sub_Category": prod["Sub_Category"],
            "Quantity": quantity,
            "Sales": sales,
            "Discount": round(base_discount, 2),
            "Profit": profit,
            "Region": region,
            "State": state,
            "City": city,
            "Payment_Mode": payment_mode,
            "Shipping_Mode": shipping_mode,
        })

    return pd.DataFrame(records)


# ----------------------------------------------------------------------
# Inject realistic data-quality issues
# ----------------------------------------------------------------------
def inject_data_quality_issues(df):
    df = df.copy()
    n = len(df)
    rng = np.random.default_rng(SEED)

    # 1. Missing values in several columns (different missingness mechanisms)
    for col, frac in [("Customer_Name", 0.01), ("Discount", 0.015),
                       ("City", 0.02), ("Payment_Mode", 0.01), ("Sales", 0.005)]:
        idx = rng.choice(n, size=int(n * frac), replace=False)
        df.loc[idx, col] = np.nan

    # 2. Duplicate records (exact duplicate rows, simulating double-submission)
    dup_idx = rng.choice(n, size=int(n * 0.012), replace=False)
    duplicates = df.loc[dup_idx]
    df = pd.concat([df, duplicates], ignore_index=True)

    # 3. Inconsistent categorical formatting (casing / whitespace)
    inconsistent_idx = rng.choice(len(df), size=int(len(df) * 0.05), replace=False)
    for i in inconsistent_idx:
        variant = rng.integers(0, 4)
        val = df.loc[i, "Region"]
        if isinstance(val, str):
            if variant == 0:
                df.loc[i, "Region"] = val.upper()
            elif variant == 1:
                df.loc[i, "Region"] = val.lower()
            elif variant == 2:
                df.loc[i, "Region"] = f" {val} "
            else:
                df.loc[i, "Region"] = val + "  "

    payment_variant_idx = rng.choice(len(df), size=int(len(df) * 0.03), replace=False)
    for i in payment_variant_idx:
        val = df.loc[i, "Payment_Mode"]
        if isinstance(val, str):
            df.loc[i, "Payment_Mode"] = val.replace(" ", "_").lower()

    # 4. A few invalid / impossible values
    invalid_qty_idx = rng.choice(len(df), size=25, replace=False)
    df.loc[invalid_qty_idx, "Quantity"] = -1  # negative quantity (data entry error)

    invalid_discount_idx = rng.choice(len(df), size=15, replace=False)
    df.loc[invalid_discount_idx, "Discount"] = 1.5  # discount > 100% (impossible)

    invalid_sales_idx = rng.choice(len(df), size=20, replace=False)
    df.loc[invalid_sales_idx, "Sales"] = 0  # zero-value order lines (system glitch)

    # 5. A handful of extreme outliers in Sales (genuine bulk/corporate orders, not errors)
    outlier_idx = rng.choice(len(df), size=10, replace=False)
    df.loc[outlier_idx, "Sales"] = df.loc[outlier_idx, "Sales"] * rng.uniform(8, 15, size=10)
    df.loc[outlier_idx, "Quantity"] = df.loc[outlier_idx, "Quantity"] * 6

    # 6. Date inconsistencies: some dates stored in different string formats,
    #    a few future dates, a few impossible/blank dates
    df["Order_Date"] = df["Order_Date"].astype(object)
    date_format_idx = rng.choice(len(df), size=int(len(df) * 0.04), replace=False)
    for i in date_format_idx:
        d = df.loc[i, "Order_Date"]
        if isinstance(d, pd.Timestamp):
            fmt_choice = rng.integers(0, 3)
            if fmt_choice == 0:
                df.loc[i, "Order_Date"] = d.strftime("%d-%m-%Y")
            elif fmt_choice == 1:
                df.loc[i, "Order_Date"] = d.strftime("%m/%d/%Y")
            else:
                df.loc[i, "Order_Date"] = d.strftime("%Y/%m/%d")

    future_date_idx = rng.choice(len(df), size=8, replace=False)
    df.loc[future_date_idx, "Order_Date"] = pd.Timestamp("2027-01-15")

    blank_date_idx = rng.choice(len(df), size=12, replace=False)
    df.loc[blank_date_idx, "Order_Date"] = np.nan

    # 7. Duplicate Order_ID with different content (rare true data error, not the
    #    intentional exact-duplicate case above)
    dup_id_idx = rng.choice(len(df), size=6, replace=False)
    df.loc[dup_id_idx, "Order_ID"] = "ORD-000001"

    return df


def main():
    print("Generating customers...")
    customers_df = build_customers(N_CUSTOMERS)

    print("Generating product catalogue...")
    products_df = build_products()
    print(f"  {len(products_df)} products created across {len(CATEGORY_SUBCATEGORY)} categories")

    print(f"Generating {N_ORDERS} order-line records...")
    orders_df = generate_orders(customers_df, products_df, N_ORDERS)

    print("Injecting realistic data-quality issues...")
    dirty_df = inject_data_quality_issues(orders_df)

    # Shuffle rows so duplicates/injected issues aren't clustered at the end
    dirty_df = dirty_df.sample(frac=1, random_state=SEED).reset_index(drop=True)

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    dirty_df.to_csv(OUTPUT_PATH, index=False)
    print(f"Saved raw dataset to {OUTPUT_PATH}")
    print(f"Final shape: {dirty_df.shape}")


if __name__ == "__main__":
    main()
