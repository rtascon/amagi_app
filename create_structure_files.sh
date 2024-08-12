#!/bin/bash

# Crear carpetas para el frontend
mkdir -p frontend/lib \
         frontend/assets \
         frontend/test

# Crear carpetas para el backend
mkdir -p backend/app/controllers \
         backend/app/models \
         backend/app/views \
         backend/app/services \
         backend/app/repositories \
         backend/app/schemas \
         backend/app/core \
         backend/app/config \
         backend/tests \
         backend/logs

# Crear archivos vacíos en las carpetas frontend
touch frontend/lib/main.dart \
      frontend/assets/.gitkeep \
      frontend/test/widget_test.dart

# Crear archivos vacíos en las carpetas backend
touch backend/app/controllers/__init__.py \
      backend/app/models/__init__.py \
      backend/app/views/__init__.py \
      backend/app/services/__init__.py \
      backend/app/repositories/__init__.py \
      backend/app/schemas/__init__.py \
      backend/app/core/__init__.py \
      backend/app/config/__init__.py \
      backend/tests/test_main.py \
      backend/logs/.gitkeep

echo "Estructura del proyecto creada exitosamente."
