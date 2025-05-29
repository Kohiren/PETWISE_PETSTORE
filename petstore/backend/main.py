from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import os
from werkzeug.utils import secure_filename
from flask import send_from_directory
from datetime import datetime

app = Flask(__name__)
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
assets_folder = os.path.join(project_root, 'assets')

app = Flask(__name__, static_url_path='/assets', static_folder=assets_folder)

CORS(app)

UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)  # Ensure folder exists

# Database connection function
def get_db_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",  # Provide your password here if necessary
        database="last"
    )

# LOGIN PHASE =======================================
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.get_json()

        if not data or 'email' not in data or 'password' not in data:
            return jsonify({"message": "Email and password are required"}), 400

        email = data['email']
        password = data['password']

        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = "SELECT * FROM signup WHERE email = %s AND password = %s"
        cursor.execute(query, (email, password))
        user = cursor.fetchone()

        cursor.close()
        conn.close()

        if user:
            user.pop('password', None)
            user.pop('conpas', None)

            return jsonify({
                "message": "Login successful",
                "user": {
                    'firstname': user['firstname'],
                    'email': user['email'],
                    'phone': user['phone'],
                    'barangay': user['barangay'],
                    'province': user['province'],
                    'municipality': user['municipality'],
                    'zipcode': user['zipcode'],
                    'role': user['role'],
                }
            }), 200
        else:
            return jsonify({"message": "Invalid email or password"}), 401

    except Exception as e:
        return jsonify({"message": "Server error", "error": str(e)}), 500



# BUYER SIGNUP PHASE =======================================

# Define the path to the upload folder (make sure the directory exists)
UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'petstore (mobile)', 'uploads')

@app.route('/signup', methods=['POST'])
def signup():
    try:
        # Access form fields
        firstname = request.form.get('firstname')
        middlename = request.form.get('middlename')
        lastname = request.form.get('lastname')
        email = request.form.get('email')
        password = request.form.get('password')
        conpas = request.form.get('conpas')
        phone = request.form.get('phone')
        province = request.form.get('province')
        municipality = request.form.get('municipality')
        barangay = request.form.get('barangay')
        zipcode = request.form.get('zipcode')
        role = request.form.get('role')

        # Get file
        valid_id_file = request.files.get('valid_id')
        if not valid_id_file:
            return jsonify({"message": "Valid ID image is required"}), 400

        # Use original filename (e.g. "Bank Card.jpg")
        original_filename = secure_filename(valid_id_file.filename)
        
        # Ensure that the upload directory exists
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)
        
        # Save the file to the specific directory
        save_path = os.path.join(UPLOAD_FOLDER, original_filename)
        valid_id_file.save(save_path)

        # Connect to database
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if user already exists
        cursor.execute("SELECT * FROM signup WHERE email = %s", (email,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"message": "User with this email already exists"}), 409

        # Insert user
        query = """
            INSERT INTO signup (
                firstname, middlename, lastname, email, password, conpas, phone,
                province, municipality, barangay, zipcode, valid_id, role
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        values = (
            firstname, middlename, lastname, email, password, conpas, phone,
            province, municipality, barangay, zipcode, original_filename, role
        )

        cursor.execute(query, values)
        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({"message": "Signup successful"}), 201

    except Exception as e:
        return jsonify({"message": "Server error", "error": str(e)}), 500


# SELLER SIGNUP PHASE =======================================

@app.route('/seller_signup', methods=['POST'])
def seller_signup():
    try:
        # Get form data
        business_name = request.form.get('business_name')
        firstname = request.form.get('firstname')
        middlename = request.form.get('middlename')
        lastname = request.form.get('lastname')
        seller_email = request.form.get('seller_email')
        password = request.form.get('password')
        conpas = request.form.get('conpas')
        phone = request.form.get('phone')
        province = request.form.get('province')
        municipality = request.form.get('municipality')
        barangay = request.form.get('barangay')
        zipcode = request.form.get('zipcode')
        role = request.form.get('role')

        # Check if any field is missing
        if not all([business_name, firstname, lastname, seller_email, password, conpas, phone, province, municipality, barangay, zipcode, role]):
            return jsonify({"message": "Missing required fields"}), 400
        
        # File uploads
        valid_id_file = request.files.get('valid_id')
        business_permit_file = request.files.get('business_permit')
        
        if not valid_id_file:
            return jsonify({"message": "Valid ID file is required"}), 400
        
        if not business_permit_file:
            return jsonify({"message": "Business permit file is required"}), 400

        # Save all uploaded files
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)

        valid_id_filename = secure_filename(valid_id_file.filename)
        business_permit_filename = secure_filename(business_permit_file.filename)

        valid_id_file.save(os.path.join(UPLOAD_FOLDER, valid_id_filename))
        business_permit_file.save(os.path.join(UPLOAD_FOLDER, business_permit_filename))

        # Connect to DB
        conn = get_db_connection()
        cursor = conn.cursor()

        # Check if seller already exists
        cursor.execute("SELECT * FROM seller_signup WHERE seller_email = %s", (seller_email,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({"message": "Seller with this email already exists"}), 409

        # Insert into seller_signup
        query = """
            INSERT INTO seller_signup (
                business_name, firstname, middlename, lastname,
                seller_email, password, conpas, phone, province,
                municipality, barangay, zipcode, valid_id,
                business_permit, role
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        values = (
            business_name, firstname, middlename, lastname,
            seller_email, password, conpas, phone, province,
            municipality, barangay, zipcode,
            valid_id_filename, business_permit_filename, role
        )

        cursor.execute(query, values)
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Seller signup successful"}), 201

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"message": "Server error", "error": str(e)}), 500
    

# PRODUCT PHASE =======================================

@app.route('/products', methods=['GET'])
def get_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT id, name, price, variation, description, category, image_path, quantity
            FROM seller_addprdct
        """)
        products = cursor.fetchall()
        cursor.close()
        conn.close()

        base_url = request.host_url.rstrip('/')  # Get the base URL
        for product in products:
            product['image_path'] = f"{base_url}/assets/uploads/{product['image_path']}"  # Construct full URL for images
        return jsonify(products)

    except Exception as e:
        return jsonify({'error': str(e)})
    
@app.route('/second_products', methods=['GET'])
def get_all_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT * FROM seller_addprdct")
        products = cursor.fetchall()

        return jsonify(products)

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# Dog food products endpoint
@app.route('/dogfood_products', methods=['GET'])
def get_dogfood_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT name, price, image_path 
            FROM seller_addprdct 
            WHERE LOWER(category) LIKE '%dog-food%'
               OR LOWER(category) LIKE '%dog food%'
               OR LOWER(category) LIKE '%dog%'
        """
        cursor.execute(query)
        products = cursor.fetchall()

        product_list = []
        for p in products:
            image_path = f'/assets/Dog Food and Treats/{p["image_path"]}' if p.get('image_path') else ''
            product_list.append({
                'name': p['name'],
                'price': p['price'],
                'image_path': image_path
            })

        cursor.close()
        conn.close()

        return jsonify(product_list)

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

@app.route('/catacc_products', methods=['GET'])
def get_catacc_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT name, price, image_path 
            FROM seller_addprdct 
            WHERE LOWER(category) LIKE '%cat-litter%' OR LOWER(category) LIKE '%cat%' OR LOWER(category) LIKE '%accessories%'
        """
        cursor.execute(query)
        products = cursor.fetchall()

        product_list = []
        for p in products:
            image_path = f'/assets/Cat Litter and Accessories/{p["image_path"]}' if p.get('image_path') else ''
            product_list.append({
                'name': p['name'],
                'price': p['price'],
                'image_path': image_path
            })

        cursor.close()
        conn.close()

        return jsonify(product_list)

    except Exception as e:
        return jsonify({'error': str(e)}), 500

    
@app.route('/aquafish_products', methods=['GET'])
def get_aquafish_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Using LIKE for flexible matching (case-insensitive)
        query = """
            SELECT name, price, image_path 
            FROM seller_addprdct 
            WHERE LOWER(category) LIKE '%aquarium-fish%'
               OR LOWER(category) LIKE '%aquarium-fish%'
               OR LOWER(category) LIKE '%aqua%'
        """
        cursor.execute(query)
        products = cursor.fetchall()

        product_list = []
        for p in products:
            # Adjust image_path based on how you store images
            image_path = f'/assets/Aquarium Fish Supplies/{p["image_path"]}' if p.get('image_path') else ''
            product_list.append({
                'name': p['name'],
                'price': p['price'],
                'image_path': image_path
            })

        cursor.close()
        conn.close()

        return jsonify(product_list)

    except Exception as e:
        return jsonify({'error': str(e)}), 500



@app.route('/birdfeed_products', methods=['GET'])
def get_birdfeed_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Using LIKE for flexible matching (case-insensitive)
        query = """
            SELECT name, price, image_path 
            FROM seller_addprdct 
            WHERE LOWER(category) LIKE '%bird-feeders%'
               OR LOWER(category) LIKE '%bird-feeders%'
               OR LOWER(category) LIKE '%bird%'
        """
        cursor.execute(query)
        products = cursor.fetchall()

        product_list = []
        for p in products:
            # Adjust image_path based on how you store images
            image_path = f'/assets/Bird Feeders & Food/{p["image_path"]}' if p.get('image_path') else ''
            product_list.append({
                'name': p['name'],
                'price': p['price'],
                'image_path': image_path
            })

        cursor.close()
        conn.close()

        return jsonify(product_list)

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
    
@app.route('/petgrooming_products', methods=['GET'])
def get_petgrooming_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Using LIKE for flexible matching (case-insensitive)
        query = """
            SELECT name, price, image_path 
            FROM seller_addprdct 
            WHERE LOWER(category) LIKE '%pet-grooming%'
               OR LOWER(category) LIKE '%pet-grooming%'
               OR LOWER(category) LIKE '%grooming%'
        """
        cursor.execute(query)
        products = cursor.fetchall()

        product_list = []
        for p in products:
            # Adjust image_path based on how you store images
            image_path = f'/assets/Pet Grooming Products/{p["image_path"]}' if p.get('image_path') else ''
            product_list.append({
                'name': p['name'],
                'price': p['price'],
                'image_path': image_path
            })

        cursor.close()
        conn.close()

        return jsonify(product_list)

    except Exception as e:
        return jsonify({'error': str(e)}), 500



@app.route('/pethealth_products', methods=['GET'])
def get_pethealth_products():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Using LIKE for flexible matching (case-insensitive)
        query = """
            SELECT name, price, image_path 
            FROM seller_addprdct 
            WHERE LOWER(category) LIKE '%pet-health%'
               OR LOWER(category) LIKE '%pet-health%'
               OR LOWER(category) LIKE '%health%'
        """
        cursor.execute(query)
        products = cursor.fetchall()

        product_list = []
        for p in products:
            # Adjust image_path based on how you store images
            image_path = f'/assets/Pet Health and Wellness/{p["image_path"]}' if p.get('image_path') else ''
            product_list.append({
                'name': p['name'],
                'price': p['price'],
                'image_path': image_path
            })

        cursor.close()
        conn.close()

        return jsonify(product_list)

    except Exception as e:
        return jsonify({'error': str(e)}), 500


# CART PHASE =======================================

# Cart endpoint with full image path
@app.route('/cart', methods=['GET'])
def get_cart_items():
    base_url = "http://192.168.254.185:5000"  # Change to your server IP or domain
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, image_path, name, price, quantity FROM cart")
    items = cursor.fetchall()

    for item in items:
        item['image_path'] = f"{base_url}/assets/uploads/{item['image_path']}"

    cursor.close()
    conn.close()
    return jsonify(items)

@app.route('/api/cart/<int:item_id>', methods=['DELETE'])
def delete_apicart_item(item_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM cart WHERE id = %s", (item_id,))
    conn.commit()
    affected_rows = cursor.rowcount
    cursor.close()
    conn.close()

    if affected_rows == 0:
        return jsonify({"error": "Item not found"}), 404

    return jsonify({"message": f"Item {item_id} deleted"}), 200

@app.route('/api/cart', methods=['GET'])
def get_apicart_items():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM cart")
    items = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(items), 200

@app.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    data = request.json
    print("Received data:", data)  # ✅ Debug log

    name = data.get('name')
    image_path = data.get('image_path')
    price = data.get('price')
    quantity = data.get('quantity')
    buyer_email = data.get('buyer_email')  # Get the buyer's email

    # Extract just the filename
    image_filename = os.path.basename(image_path) if image_path else None

    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Check if the item is already in the cart for this buyer
        cursor.execute("SELECT quantity FROM cart WHERE name = %s AND buyer_email = %s", (name, buyer_email))
        result = cursor.fetchone()

        if result:
            # Item exists, update quantity
            current_quantity = result[0]
            new_quantity = current_quantity + int(quantity)
            cursor.execute("UPDATE cart SET quantity = %s WHERE name = %s AND buyer_email = %s", (new_quantity, name, buyer_email))
        else:
            # Item does not exist, insert new
            cursor.execute(
                "INSERT INTO cart (name, image_path, price, quantity, buyer_email) VALUES (%s, %s, %s, %s, %s)",
                (name, image_filename, price, quantity, buyer_email)
            )

        conn.commit()
        return jsonify({"message": "Item added to cart"}), 200

    except Exception as e:
        print("Insert/update error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()





@app.route('/cart/<int:item_id>', methods=['DELETE'])
def delete_cart_item(item_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM cart WHERE id = %s", (item_id,))
        conn.commit()
        return jsonify({'message': 'Item deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

# SEARCH PHASE =======================================

@app.route('/api/products', methods=['GET'])
def search_products():
    query = request.args.get('query', '')

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)  # Make results dict-like

    if query:
        cursor.execute("""
            SELECT name, price, image_path
            FROM seller_addprdct
            WHERE name LIKE %s
        """, (f"%{query}%",))
    else:
        cursor.execute("SELECT name, price, image_path FROM seller_addprdct")

    results = cursor.fetchall()
    cursor.close()
    conn.close()

    # Fix image paths
    for item in results:
        item['image_path'] = '/assets/uploads/' + os.path.basename(item['image_path'])

    return jsonify(results)

@app.route('/api/checkout', methods=['POST'])
def checkout():
    data = request.json

    product_image = data.get('product_image')
    product_name = data.get('product_name')
    price = data.get('price')
    quantity = data.get('quantity')
    address = data.get('address')
    shipping_method = data.get('shipping_method')
    payment_method = data.get('payment_method')
    total_amount = data.get('total_amount')
    status = data.get('status', 'Pending')

    # Hardcode buyer_email as requested
    buyer_email = 'roxasaljenjovi@gmail.com'

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # 🔍 Fetch the seller_email from seller_addprdct using product_name
        cursor.execute("SELECT seller_email FROM seller_addprdct WHERE name = %s", (product_name,))
        seller_result = cursor.fetchone()

        if not seller_result:
            return jsonify({'error': 'Seller not found for this product.'}), 404

        seller_email = seller_result[0]

        # 📝 Insert checkout data including hardcoded buyer_email and fetched seller_email
        query = """
            INSERT INTO checkout (
                product_image, product_name, price, quantity,
                address, shipping_method,
                payment_method, total_amount, created_at,
                status, seller_email, buyer_email
            ) VALUES (
                %s, %s, %s, %s,
                %s, %s, %s, %s,
                %s, %s, %s, %s
            )
        """

        now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        cursor.execute(query, (
            product_image, product_name, price, quantity,
            address, shipping_method,
            payment_method, total_amount, now,
            status, seller_email, buyer_email # Include buyer_email here
        ))
        conn.commit()

        return jsonify({'message': 'Checkout successful'}), 200
    except Exception as e:
        # It's good practice to log the full exception for debugging
        print(f"Error during checkout: {e}")
        return jsonify({'error': str(e)}), 500
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

            
@app.route('/api/assigned_deliveries', methods=['GET'])
def get_assigned_deliveries():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("SELECT product_name, address, created_at FROM ship_order")
        rows = cursor.fetchall()

        # Optional: Format datetime for consistency
        for row in rows:
            row['created_at'] = row['created_at'].strftime('%Y-%m-%d %H:%M:%S')

        return jsonify(rows), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@app.route('/api/mark_delivered', methods=['POST'])
def mark_delivered():
    data = request.json
    product_name = data.get('product_name')
    address = data.get('address')
    created_at = data.get('created_at')

    if not product_name or not address or not created_at:
        return jsonify({"error": "Missing required fields"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # 🔍 Fetch full data from ship_order
        cursor.execute("""
            SELECT * FROM ship_order
            WHERE product_name = %s AND address = %s AND created_at = %s
        """, (product_name, address, created_at))
        order = cursor.fetchone()

        if not order:
            return jsonify({"error": "Order not found"}), 404

        # 📝 Insert full order data into receive_order
        insert_query = """
            INSERT INTO receive_order (
                product_image, product_name, price, quantity, address,
                shipping_method, total_amount, created_at,
                seller_email, buyer_email
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(insert_query, (
            order['product_image'], order['product_name'], order['price'],
            order['quantity'], order['address'], order['shipping_method'],
            order['total_amount'], order['created_at'],
            order['seller_email'], order['buyer_email']
        ))

        # 🗑️ Delete the transferred order from ship_order
        delete_query = """
            DELETE FROM ship_order
            WHERE product_name = %s AND address = %s AND created_at = %s
        """
        cursor.execute(delete_query, (product_name, address, created_at))

        conn.commit()
        return jsonify({"message": "Order marked as delivered and removed from ship_order"}), 201

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

    finally:
        cursor.close()
        conn.close()

def fetch_orders(table_name):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()
    conn.close()
    return rows

@app.route('/checkout', methods=['GET'])
def get_checkout_orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM checkout")
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(orders)

@app.route('/receive_order', methods=['GET'])
def get_receive_orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM receive_order")
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(orders)

@app.route('/mark_order_received', methods=['POST'])
def mark_order_received():
    data = request.get_json()
    order_id = data.get('id')  # The order ID passed from the client

    # Connect to the database
    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        # Fetch the order details from the receive_order table using the order ID
        cursor.execute("SELECT * FROM receive_order WHERE id = %s", (order_id,))
        order = cursor.fetchone()

        if order:
            # Extract seller_email from the order data
            seller_email = order[10]  # Assuming seller_email is in the 11th column (index 10)

            # Get the business_name from the seller_signup table based on seller_email
            cursor.execute("SELECT business_name FROM seller_signup WHERE seller_email = %s", (seller_email,))
            seller_info = cursor.fetchone()

            if not seller_info:
                return jsonify(success=False, message="Seller information not found.")

            business_name = seller_info[0]  # Assuming business_name is the first column in the result

            # Fetch all items for the seller_email from the receive_order table
            cursor.execute("SELECT * FROM receive_order WHERE seller_email = %s", (seller_email,))
            orders = cursor.fetchall()

            if not orders:
                return jsonify(success=False, message="No orders found for the seller.")

            for order in orders:
                # Check if the total_amount column exists in the fetched data
                if len(order) < 8:
                    return jsonify(success=False, message="Missing expected columns in the order data.")

                # Extract the necessary fields from the order
                total_amount = order[7]  # Total amount is assumed to be in the 8th column (index 7)
                buyer_email = order[11]  # Assuming buyer_email is in column 12

                # Debugging: Check the value of total_amount
                print(f"Fetched total_amount: {total_amount} (type: {type(total_amount)})")

                # Try to convert total_amount to a float explicitly
                try:
                    total_amount = float(total_amount)
                except (ValueError, TypeError):
                    return jsonify(success=False, message="Invalid total amount in the order. It must be a number.")

                # Calculate the updated total amount (subtract 35 from total_amount)
                updated_total_amount = total_amount - 35

                # Calculate the 5% commission to be subtracted
                total_sales = updated_total_amount * 0.95
                admin_commission = updated_total_amount * 0.05

                # Insert the order details into the complete_order table, including the admin_commission
                insert_query = """
                    INSERT INTO complete_order 
                    (product_image, product_name, price, quantity, address, shipping_method, total_amount, created_at, seller_email, buyer_email, admin_commission, total_sales, business_name)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """
                cursor.execute(insert_query, 
                               (order[1], order[2], order[3], order[4], order[5], order[6], updated_total_amount, order[8], seller_email, buyer_email, admin_commission, total_sales, business_name))

            # Delete all the seller's orders from the receive_order table after moving them to complete_order
            delete_query = "DELETE FROM receive_order WHERE seller_email = %s"
            cursor.execute(delete_query, (seller_email,))

            # Commit the changes to the database
            connection.commit()
            return jsonify(success=True)

        return jsonify(success=False, message="Order not found.")

    except mysql.connector.Error as err:
        # Provide a more specific error message for database-related errors
        print(f"Error: {err}")
        return jsonify(success=False, message=f"Database error occurred: {err}")

    except Exception as e:
        # Catch any other unexpected errors
        print(f"Unexpected error: {e}")
        return jsonify(success=False, message=f"Unexpected error occurred: {e}")

    finally:
        cursor.close()
        connection.close()
    
@app.route('/complete_order', methods=['GET'])
def get_complete_orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM complete_order")
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(orders)

@app.route('/cancelled_order', methods=['GET'])
def get_cancelled_orders():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM cancelled_order")
    orders = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(orders)


@app.route('/api/cancel_order', methods=['POST'])
def cancel_order():
    data = request.get_json()
    product_name = data.get('product_name')
    address = data.get('address')
    created_at_str = data.get('created_at')

    print("Received cancel request:", product_name, address, created_at_str)  # DEBUG

    if not (product_name and address and created_at_str):
        return jsonify({'error': 'Missing data'}), 400

    try:
        # Parse incoming created_at string
        created_at = datetime.strptime(created_at_str, '%a, %d %b %Y %H:%M:%S %Z')
        # Format to match MySQL timestamp
        created_at_formatted = created_at.strftime('%Y-%m-%d %H:%M:%S')

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT product_image, product_name, price, quantity, address, shipping_method, 
                   total_amount, created_at, seller_email, buyer_email 
            FROM checkout 
            WHERE product_name=%s AND address=%s AND created_at=%s
        """, (product_name, address, created_at_formatted))

        order = cursor.fetchone()

        print("Fetched order from DB:", order)  # DEBUG

        if not order:
            cursor.close()
            conn.close()
            return jsonify({'error': 'Order not found'}), 404

        cancellation_reason = "Cancelled by user"

        cursor.execute("""
            INSERT INTO cancelled_order (
                product_image, product_name, price, quantity, address, 
                shipping_method, total_amount, created_at, 
                cancellation_reason, seller_email, buyer_email
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, order + (cancellation_reason,))

        cursor.execute("DELETE FROM checkout WHERE product_name=%s AND address=%s AND created_at=%s",
                       (product_name, address, created_at_formatted))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': 'Order cancelled successfully'}), 200

    except Exception as e:
        print("Error cancelling order:", str(e))
        return jsonify({'error': 'Server error'}), 500


# --- Upload Folder Configuration ---
def insert_feedback(rating, message, photo_filename, video_filename, product_name, product_image, firstname, profile_picture):
    connection = get_db_connection()
    cursor = connection.cursor()
    try:
        insert_query = """
            INSERT INTO user_feedback (rating, message, photo_path, video_path, product_name, product_image, firstname, profile_picture)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(insert_query, (
            rating, message, photo_filename, video_filename, product_name, product_image, firstname, profile_picture
        ))
        connection.commit()
    except mysql.connector.Error as err:
        print(f"Database error: {err}")
        raise err
    finally:
        cursor.close()
        connection.close()

app.config['PHOTO_UPLOAD_FOLDER'] = 'assets/uploads/photos'
app.config['VIDEO_UPLOAD_FOLDER'] = 'assets/uploads/videos'

@app.route('/submit_feedback', methods=['POST'])
def submit_feedback():
    # Basic validation
    rating = request.form.get('rating')
    message = request.form.get('comment') or request.form.get('userMessage')
    product_name = request.form.get('product_name')
    product_image = request.form.get('product_image')
    firstname = request.form.get('firstname')
    profile_picture = request.form.get('profile_picture')

    if not rating or not message or not product_name or not firstname:
        return jsonify({'error': 'Missing required fields'}), 400

    # Handle photo upload
    photo_file = request.files.get('photos') or request.files.get('photo')
    photo_filename = None
    if photo_file and photo_file.filename != '':
        photo_filename = secure_filename(photo_file.filename)
        photo_file.save(os.path.join(app.config['PHOTO_UPLOAD_FOLDER'], photo_filename))

    # Handle video upload
    video_file = request.files.get('videos') or request.files.get('video')
    video_filename = None
    if video_file and video_file.filename != '':
        video_filename = secure_filename(video_file.filename)
        video_file.save(os.path.join(app.config['VIDEO_UPLOAD_FOLDER'], video_filename))

    # Clean product image path if needed
    if product_image and product_image.startswith("http://192.168.254.185:5000/static/uploads/"):
        product_image = product_image.replace("http://192.168.89.671:5000/static/uploads/", "")

    try:
        insert_feedback(rating, message, photo_filename, video_filename, product_name, product_image, firstname, profile_picture)
    except Exception as e:
        return jsonify({'error': 'Failed to save feedback'}), 500

    return jsonify({'message': 'Feedback submitted successfully'}), 200


@app.route('/get_feedback', methods=['GET'])
def get_feedback():
    product_name = request.args.get('product_name')  # get product name from URL query
    if not product_name:
        return jsonify({'error': 'Missing product_name parameter'}), 400

    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    try:
        query = """
            SELECT firstname, message, photo_path, video_path 
            FROM user_feedback 
            WHERE product_name = %s 
            ORDER BY id DESC
        """
        cursor.execute(query, (product_name,))
        feedback_data = cursor.fetchall()
        return jsonify(feedback_data)
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
    finally:
        cursor.close()
        connection.close()



# Accept requests from network (your phone, etc.)
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

