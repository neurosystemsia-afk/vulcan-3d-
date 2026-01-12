FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# 1. Instalar GIT y herramientas
RUN apt-get update && apt-get install -y git wget && rm -rf /var/lib/apt/lists/*

# 2. Clonar TripoSR
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git

# 3. Copiar requerimientos
COPY requirements.txt .

# 4. INSTALACIÓN BLINDADA (Aquí está la magia)
# Primero desinstalamos numpy por si acaso, y luego instalamos todo
RUN pip uninstall -y numpy && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --upgrade transformers

# 5. Copiar el resto del código
COPY . .

# 6. Arrancar
CMD [ "python", "-u", "handler.py" ]
