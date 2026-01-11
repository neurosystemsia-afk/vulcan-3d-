import sys
import os

# --- AGREGAR ESTO PARA QUE ENCUENTRE TRIPOSR ---
sys.path.append(os.path.abspath("/TripoSR"))
# -----------------------------------------------

import runpod
import torch
from tsr.system import TSR
from tsr.utils import remove_background, resize_foreground
from PIL import Image
import io
import base64
import tempfile

print("🏗️ INICIANDO VULCAN 3D...")

# Cargar el modelo en la GPU
# Nota: TripoSR descargará los pesos automáticamente la primera vez
model = TSR.from_pretrained(
    "stabilityai/TripoSR",
    config_name="config.yaml",
    weight_name="model.ckpt",
)
model.renderer.set_chunk_size(8192)
model.to("cuda")

print("✅ VULCAN 3D ONLINE: Listo para esculpir.")

def handler(event):
    input_data = event["input"]
    image_base64 = input_data.get("image_base64")
    
    if not image_base64:
        return {"error": "No enviaste ninguna imagen"}

    try:
        # 1. Decodificar la imagen
        image_data = base64.b64decode(image_base64)
        input_image = Image.open(io.BytesIO(image_data))

        # 2. Pre-procesar
        print("🎨 Procesando imagen...")
        rembg_session = None 
        input_image = remove_background(input_image, rembg_session)
        input_image = resize_foreground(input_image, 0.85)

        # 3. Generar el 3D
        print("🗿 Esculpiendo modelo 3D...")
        with torch.no_grad():
            scene_codes = model(input_image, device="cuda")

        # 4. Exportar a GLB
        print("📦 Empaquetando archivo GLB...")
        meshes = model.extract_mesh(scene_codes)[0]
        
        tmp_path = tempfile.mktemp(suffix=".glb")
        meshes.export(tmp_path)
        
        with open(tmp_path, "rb") as f:
            glb_base64 = base64.b64encode(f.read()).decode("utf-8")

        return {
            "status": "success",
            "model_glb_base64": glb_base64
        }

    except Exception as e:
        print(f"❌ Error: {e}")
        return {"status": "error", "message": str(e)}

runpod.serverless.start({"handler": handler})
