import sys
import os

# Forzar la ruta de TripoSR por si el Dockerfile falló en el ENV
sys.path.append("/TripoSR")

import runpod
import torch
import io
import base64
import tempfile
import numpy as np
from PIL import Image
from tsr.system import TSR
from tsr.utils import remove_background, resize_foreground

print("🏗️ INICIANDO VULCAN 3D (TripoSR Engine)...")

# Cargar modelo (TripoSR bajará los pesos automáticamente a ~/.cache)
try:
    model = TSR.from_pretrained(
        "stabilityai/TripoSR",
        config_name="config.yaml",
        weight_name="model.ckpt",
    )
    # Ajuste para GPU (Aumentar chunk_size si tienes una 4090, bajarlo si falla la memoria)
    model.renderer.set_chunk_size(8192)
    model.to("cuda")
    print("✅ VULCAN 3D ONLINE: Sistema listo.")
except Exception as e:
    print(f"❌ ERROR CRÍTICO CARGANDO MODELO: {e}")
    sys.exit(1) # Matar el pod si no carga el modelo

def handler(event):
    input_data = event.get("input", {})
    image_base64 = input_data.get("image_base64")
    
    if not image_base64:
        return {"error": "No se recibió 'image_base64'"}

    try:
        # 1. Decodificar Base64 a Imagen
        image_data = base64.b64decode(image_base64)
        input_image = Image.open(io.BytesIO(image_data))

        # 2. Pre-procesamiento (Quitar fondo + Resize)
        print("🎨 Procesando imagen (Rembg)...")
        rembg_session = None
        input_image = remove_background(input_image, rembg_session)
        input_image = resize_foreground(input_image, 0.85)

        # 3. Inferencia (Generar 3D)
        print("🗿 Generando geometría...")
        with torch.no_grad():
            scene_codes = model(input_image, device="cuda")

        # 4. Exportar a GLB
        print("📦 Exportando a GLB...")
        meshes = model.extract_mesh(scene_codes)[0]
        
        # Guardar en temporal y convertir a Base64
        tmp_path = tempfile.mktemp(suffix=".glb")
        meshes.export(tmp_path)
        
        with open(tmp_path, "rb") as f:
            glb_base64 = base64.b64encode(f.read()).decode("utf-8")

        return {
            "status": "success",
            "model_glb_base64": glb_base64
        }

    except Exception as e:
        print(f"❌ Error en generación: {e}")
        return {"status": "error", "message": str(e)}

runpod.serverless.start({"handler": handler})
