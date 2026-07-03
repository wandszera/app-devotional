import logging
import os

import firebase_admin
from firebase_admin import credentials

logger = logging.getLogger(__name__)

def init_firebase() -> bool:
    service_account_path = "serviceAccountKey.json"
    
    if os.path.exists(service_account_path):
        try:
            cred = credentials.Certificate(service_account_path)
            if not firebase_admin._apps:
                firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin inicializado com sucesso.")
            return True
        except Exception as e:
            logger.error(f"Erro ao inicializar Firebase Admin: {e}")
            return False
    else:
        logger.warning(f"{service_account_path} nao encontrado. Notificacoes reais nao vao funcionar.")
        return False
