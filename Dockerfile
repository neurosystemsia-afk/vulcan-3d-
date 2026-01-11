FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# 1. Instalar GIT y herramientas del sistema (CRÍTICO)
RUN apt-get update && apt-get install -y git wget && rm -rf /var/lib/apt/lists/*

# 2. Clonar el repositorio de TripoSR manualmente
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git

# 3. Instalar las dependencias de TripoSR
WORKDIR /TripoSR
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --upgrade transformers

# 4. Volver al directorio principal
WORKDIR /

# 5. Copiar tus requerimientos y tu handler
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# 6. Arrancar
CMD [ "python", "-u", "handler.py" ]
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# 1. Instalar GIT
RUN apt-get update && apt-get install -y git wget && rm -rf /var/lib/apt/lists/*

# 2. Clonar el repositorio de TripoSR (Solo bajamos el código)
RUN git clone https://github.com/VAST-AI-Research/TripoSR.git

# 3. Copiar e instalar tus requerimientos (SIN TORCH)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copiar el resto de tu código
COPY . .

# 5. Arrancar
CMD [ "python", "-u", "handler.py" ]
