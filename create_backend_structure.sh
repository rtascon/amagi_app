#!/bin/bash

# Definir el directorio raíz del proyecto
PROJECT_ROOT="backend"

# Crear la estructura de carpetas
mkdir -p $PROJECT_ROOT/app/api/tickets
mkdir -p $PROJECT_ROOT/app/api/solicitudes
mkdir -p $PROJECT_ROOT/app/model
mkdir -p $PROJECT_ROOT/app/repository
mkdir -p $PROJECT_ROOT/app/dto
mkdir -p $PROJECT_ROOT/app/dao
mkdir -p $PROJECT_ROOT/app/services
mkdir -p $PROJECT_ROOT/app/schemas
mkdir -p $PROJECT_ROOT/app/config
mkdir -p $PROJECT_ROOT/app/controllers
mkdir -p $PROJECT_ROOT/app/tests
mkdir -p $PROJECT_ROOT/migrations
mkdir -p $PROJECT_ROOT/alembic
mkdir -p $PROJECT_ROOT/docs

# Crear archivos vacíos
touch $PROJECT_ROOT/app/api/tickets/__init__.py
touch $PROJECT_ROOT/app/api/tickets/ticket_routes.py
touch $PROJECT_ROOT/app/api/tickets/ticket_endpoints.py
touch $PROJECT_ROOT/app/api/solicitudes/__init__.py
touch $PROJECT_ROOT/app/api/solicitudes/solicitud_routes.py
touch $PROJECT_ROOT/app/api/solicitudes/solicitud_endpoints.py
touch $PROJECT_ROOT/app/model/__init__.py
touch $PROJECT_ROOT/app/model/ticket_model.py
touch $PROJECT_ROOT/app/model/solicitud_model.py
touch $PROJECT_ROOT/app/repository/__init__.py
touch $PROJECT_ROOT/app/repository/ticket_repository.py
touch $PROJECT_ROOT/app/repository/solicitud_repository.py
touch $PROJECT_ROOT/app/dto/__init__.py
touch $PROJECT_ROOT/app/dto/ticket_dto.py
touch $PROJECT_ROOT/app/dto/solicitud_dto.py
touch $PROJECT_ROOT/app/dao/__init__.py
touch $PROJECT_ROOT/app/dao/ticket_dao.py
touch $PROJECT_ROOT/app/dao/solicitud_dao.py
touch $PROJECT_ROOT/app/services/__init__.py
touch $PROJECT_ROOT/app/services/database_connection.py
touch $PROJECT_ROOT/app/services/authentication_service.py
touch $PROJECT_ROOT/app/services/authorization_service.py
touch $PROJECT_ROOT/app/services/file_upload_service.py
touch $PROJECT_ROOT/app/services/logging_service.py
touch $PROJECT_ROOT/app/services/notification_service.py
touch $PROJECT_ROOT/app/schemas/__init__.py
touch $PROJECT_ROOT/app/schemas/ticket_schema.py
touch $PROJECT_ROOT/app/schemas/solicitud_schema.py
touch $PROJECT_ROOT/app/config/__init__.py
touch $PROJECT_ROOT/app/config/settings.py
touch $PROJECT_ROOT/app/controllers/__init__.py
touch $PROJECT_ROOT/app/controllers/ticket_controller.py
touch $PROJECT_ROOT/app/controllers/solicitud_controller.py
touch $PROJECT_ROOT/app/tests/__init__.py
touch $PROJECT_ROOT/app/tests/test_ticket.py
touch $PROJECT_ROOT/app/tests/test_solicitud.py
touch $PROJECT_ROOT/app/main.py
touch $PROJECT_ROOT/migrations/.gitkeep
touch $PROJECT_ROOT/alembic/.gitkeep
touch $PROJECT_ROOT/docs/.gitkeep

echo "Estructura de carpetas y archivos creada con éxito."
