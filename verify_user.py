import os
from supabase import create_client
from dotenv import load_dotenv

load_dotenv()

url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

supabase = create_client(url, key)

print("Fetching users...")
response = supabase.auth.admin.list_users()
for user in response:
    if user.email == "admin@mbg.com":
        print(f"Found user: {user.email}, ID: {user.id}")
        supabase.auth.admin.update_user_by_id(user.id, {"email_confirm": True})
        print("User successfully confirmed!")
        break
else:
    print("User admin@mbg.com not found.")
