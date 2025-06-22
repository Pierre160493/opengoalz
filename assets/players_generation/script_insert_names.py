import csv
import os

def read_csv_file(table_to_insert, id_country):
    """
    Reads a CSV file for a given table and country ID and returns the rows.

    Args:
        table_to_insert (str): The name of the table to insert data into.
        id_country (int): The ID of the country.

    Returns:
        list: A list of dictionaries, each representing a row from the CSV file.

    Raises:
        FileNotFoundError: If no CSV file is found matching the criteria.
        ValueError: If multiple CSV files are found matching the criteria.
    """
    # List all files in the directory that start with id_country
    matching_files = [f for f in os.listdir(table_to_insert) if f.startswith(str(id_country)) and f.endswith(".csv")]

    # Check the number of matching files
    if len(matching_files) == 0:
        print(f"Error: No CSV file found for '{table_to_insert}' starting with id_country = {id_country}.")
        user_input = input("Do you want to continue by ignoring this file? (y/n): ")
        if user_input.lower() not in ('y', 'yes'):
            raise e
        else:
            return []
    elif len(matching_files) > 1:
        raise ValueError(f"Multiple CSV files found in '{table_to_insert}' starting with '{id_country}'. Please specify which file to use.")
    
    # If exactly one file is found, construct the full path
    input_csv = os.path.join(table_to_insert, matching_files[0])

    try:
        # Check if the input CSV file exists
        if not os.path.exists(input_csv):
            print(f"Error: Input CSV file '{input_csv}' not found.")
            exit(1)

        with open(input_csv, mode='r', encoding='utf-8') as csv_file:
            csv_reader = csv.DictReader(csv_file)
            return list(csv_reader)  # Return the rows as a list of dictionaries

    except FileNotFoundError as e:
        print(f"Error: {e}")
        user_input = input("Do you want to continue by ignoring this file? (y/n): ")
        if user_input.lower() not in ('y', 'yes'):
            raise e
        else:
            return []
    except ValueError as e:
        print(f"Error: {e}")
        raise e
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        raise e

def process_csv_rows(rows, id_country):
    """
    Processes CSV rows to generate SQL insert statements.

    Args:
        rows (list): A list of dictionaries, each representing a row from the CSV file.
        id_country (int): The ID of the country.

    Returns:
        list: A list of strings, each representing a row to insert into the SQL database.
    """
    rows_to_insert = []
    # for row in rows:
    for row in rows[:1000]:
    # for row in rows[:5]: # Limit to first 5 rows for testing
        # Get name and weight, using .get() for safer access
        name = row.get("name") # Assuming CSV header is "name"
        name = name.replace("'", "''") # Escape single quotes for SQL
        weight = row.get("weight") # Assuming CSV header is "weight"

        # Basic validation: ensure both name and weight exist
        if name is not None and weight is not None:
            
            try:
                # Ensure weight is a valid number; if not, skip or handle error
                weight = float(weight)
                rows_to_insert.append(f"('{name}', {weight}, {id_country})")
            except ValueError:
                print(f"Warning: Skipping row due to invalid weight value: {row}")
        else:
            print(f"Warning: Skipping row due to missing 'name' or 'weight': {row}")
    return rows_to_insert

id_countries = [83] # List of country IDs to process
tables_to_insert = ["first_names", "last_names"]

# Define the input CSV file and output SQL file
output_sql = f"insert_players_names.sql"


with open(output_sql, mode='w', encoding='utf-8') as sql_file:
    sql_file.write("------------ SQL Insert Commands for tables containing players names for generation\n")
    sql_file.write("------ Generated from CSV file\n\n")
    sql_file.write("------ Clean and restart table\n")
    sql_file.write("-- TRUNCATE TABLE players_generation.first_names RESTART IDENTITY;\n")
    sql_file.write("-- TRUNCATE TABLE players_generation.last_names RESTART IDENTITY;\n")
    for table_to_insert in tables_to_insert:

        print(f"###### Processing table: {table_to_insert}")
    
        all_rows_to_insert = [] # This list will hold all the (name, weight, id_country) tuples

        for id_country in id_countries:
            print(f"### Processing country ID: {id_country}")
            
            rows_to_insert = process_csv_rows(read_csv_file(table_to_insert, id_country), id_country)
            
            if not rows_to_insert:
                print(f"# Warning: No valid data found in CSV for table '{table_to_insert}' and country ID '{id_country}'.")

            all_rows_to_insert.extend(rows_to_insert)

        print(f"### Total rows to insert for {table_to_insert}: {len(all_rows_to_insert)}")
        sql_file.write(f"\n\nINSERT INTO players_generation.{table_to_insert} (name, weight, id_country) VALUES\n")

        # Join all rows with ",\n" and add a semicolon at the very end
        sql_file.write(",\n".join(all_rows_to_insert))
        sql_file.write("\nON CONFLICT (name, id_country) DO UPDATE SET weight = EXCLUDED.weight;\n") # Add the final semicolon and a newline

print(f"###### SQL file generated successfully: {output_sql}")
