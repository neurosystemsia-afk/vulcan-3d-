FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# Instalar dependencias de sistema y git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Instalar librerías de Python básicas
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Instalar TripoSR directamente desde GitHub (es la forma segura)
RUN pip install git+https://github.com/VAST-AI-Research/TripoSR.git

# Copiar tu cerebro
COPY . .

# Arrancar
CMD [ "python", "-u", "handler.py" ]
