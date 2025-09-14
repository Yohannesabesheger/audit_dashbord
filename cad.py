# create_admin_user.py
import os
import django

# Setup Django environment
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "audit_dashboard.settings")
django.setup()

from django.contrib.auth import get_user_model

User = get_user_model()


def create_admin_user():
    username = "admin"
    email = "dashadmin@birrx.io"
    password = "Yohannes@hira123321"

    if User.objects.filter(username=username).exists():
        print("Admin user already exists.")
    else:
        User.objects.create_superuser(username=username, email=email, password=password)
        print("Admin user created successfully.")


if __name__ == "__main__":
    create_admin_user()
