# Usamos la imagen oficial de RunPod que ya trae CUDA y Python optimizado
FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Evitar preguntas de instalación
ENV DEBIAN_FRONTEND=noninteractive
# Añadir la carpeta de TripoSR al path de Python para que encuentre los módulos
ENV PYTHONPATH="${PYTHONPATH}:/TripoSR"

WORKDIR /

# 1. Instalar herramientas del sistema necesarias
RUN apt-get update && apt-get install -y git wget libgl1-mesa-glx && rm -rf /var/lib/apt/lists/*

# 2. Clonar TripoSR manualmente en la raíz
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git /TripoSR

# 3. Copiar tus requerimientos
COPY requirements.txt .

# 4. INSTALACIÓN CRÍTICA (En una sola capa para evitar conflictos)
# a) Actualizamos pip
# b) Desinstalamos numpy conflictivo
# c) Instalamos tus requerimientos
# d) Instalamos los requerimientos internos de TripoSR
RUN pip install --upgrade pip && \
    pip uninstall -y numpy && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r /TripoSR/requirements.txt

# 5. Copiar tu handler (el cerebro)
COPY . .

# 6. Ejecutar
CMD [ "python", "-u", "handler.py" ]
