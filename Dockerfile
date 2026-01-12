# Usamos la imagen oficial de RunPod (con CUDA y Python listos)
FROM runpod/pytorch:2.0.1-py3.10-cuda11.8.0-devel

# Evitar preguntas de instalación
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONPATH="${PYTHONPATH}:/TripoSR"

WORKDIR /

# 1. Instalar herramientas del sistema (CRÍTICO: build-essential para compilar torchmcubes)
RUN apt-get update && \
    apt-get install -y git wget libgl1-mesa-glx build-essential && \
    rm -rf /var/lib/apt/lists/*

# 2. Clonar TripoSR
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git /TripoSR

# 3. Copiar tus requerimientos
COPY requirements.txt .

# 4. INSTALACIÓN QUIRÚRGICA (En orden específico)
# a) Actualizamos pip y herramientas de compilación
# b) Desinstalamos numpy conflictivo y ponemos el viejo
# c) Instalamos torchmcubes DESDE EL SOURCE (para que no falle)
# d) Instalamos el resto de requerimientos
RUN pip install --upgrade pip setuptools wheel && \
    pip uninstall -y numpy && \
    pip install --no-cache-dir "numpy<2.0" && \
    pip install --no-cache-dir git+https://github.com/tatsy/torchmcubes.git && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir -r /TripoSR/requirements.txt

# 5. Copiar tu handler
COPY . .

# 6. Ejecutar
CMD [ "python", "-u", "handler.py" ]
