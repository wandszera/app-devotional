import sys
from app.db.session import SessionLocal
from app.db.models import UserModel as User

def main():
    if len(sys.argv) < 2:
        print("Uso: python make_admin.py <seu_email>")
        sys.exit(1)
        
    email = sys.argv[1]
    
    with SessionLocal() as db:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            print(f"Erro: Usuário com email '{email}' não encontrado no banco de dados.")
            print("Você precisa criar uma conta pelo aplicativo primeiro!")
            sys.exit(1)
            
        if user.is_admin:
            print(f"O usuário {email} já é um administrador!")
        else:
            user.is_admin = True
            db.commit()
            print(f"Sucesso! O usuário {email} agora é um Administrador do sistema.")
            print("Feche e abra seu aplicativo para ver a nova aba 'Admin'.")

if __name__ == "__main__":
    main()
