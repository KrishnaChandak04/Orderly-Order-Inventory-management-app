from app import create_app, db
from app.models import Role, User, Organization
from werkzeug.security import generate_password_hash

app = create_app()
with app.app_context():
    # Create roles if they don't exist
    roles_to_add = ['admin', 'manager', 'worker']
    for role_name in roles_to_add:
        if not Role.query.filter_by(name=role_name).first():
            role = Role(name=role_name)
            db.session.add(role)
            print(f"Added role: {role_name}")
    db.session.commit()

    # Create default organization if it doesn't exist
    default_org = Organization.query.filter_by(name="Default Organization").first()
    if not default_org:
        default_org = Organization(name="Default Organization")
        db.session.add(default_org)
        db.session.commit()
        print("Added Default Organization")

    # Create admin user if it doesn't exist
    if not User.query.filter_by(username='admin').first():
        admin_password = generate_password_hash('adminpass', method='pbkdf2:sha256')
        admin_user = User(
            username='admin',
            email='admin@example.com',
            password=admin_password,
            is_active=True,
            organization_id=default_org.id
        )
        admin_role = Role.query.filter_by(name='admin').first()
        if admin_role:
            admin_user.roles.append(admin_role)
        db.session.add(admin_user)
        db.session.commit()
        print("Added admin user")
    
    print("Manual seeding complete.")
