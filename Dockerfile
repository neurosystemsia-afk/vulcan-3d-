FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONPATH="${PYTHONPATH}:/TripoSR"

WORKDIR /

# 1. Instalar herramientas
RUN apt-get update && apt-get install -y git wget && rm -rf /var/lib/apt/lists/*

# 2. Clonar TripoSR
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git

# 3. Copiar requirements
COPY requirements.txt .

# 4. INSTALACIÓN DEPURADA
# Forzamos la desinstalación de numpy conflictivo
# Instalamos las dependencias explícitamente
RUN pip uninstall -y numpy && \
    pip install --no-cache-dir numpy==1.26.4 && \
    pip install --no-cache-dir einops omegaconf && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --upgrade transformers

# 5. Copiar código
COPY . .

# 6. Arrancar
CMD [ "python", "-u", "handler.py" ]
