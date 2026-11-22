import os
from contextlib import closing

import psycopg
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, EmailStr, Field

app = FastAPI(title="Portafolio API", version="1.0.0")

allowed_origins = os.getenv("CORS_ORIGINS", "http://localhost:8080,http://localhost:4173")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[origin.strip() for origin in allowed_origins.split(",") if origin.strip()],
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)

PROFILE = {
    "name": "Wendy Ramírez",
    "role": "Estudiante de Ingeniería de Sistemas",
    "location": "Sucre, Bolivia",
    "intro": "Construyo experiencias digitales útiles, claras y cuidadas en cada detalle.",
}

PROJECTS = [
    {
        "title": "Portafolio personal",
        "category": "Desarrollo web · DevOps",
        "description": "Una aplicación full stack publicada con contenedores y despliegue automatizado.",
        "tags": ["Vue 3", "FastAPI", "Docker"],
    },
    {
        "title": "El despertar del bosque",
        "category": "Realidad virtual · Unity",
        "description": "Una aventura de exploración con acertijos para devolver la vida a un bosque encantado.",
        "tags": ["Unity", "C#", "Meta Quest"],
    },
    {
        "title": "Red social universitaria",
        "category": "Diseño y desarrollo de sistemas",
        "description": "Concepto de plataforma para conectar estudiantes y compartir recursos de la universidad.",
        "tags": ["UX/UI", "React", "Comunidad"],
    },
]


class ContactMessage(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)

    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    message: str = Field(min_length=10, max_length=3000)


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/profile")
def profile():
    return PROFILE


@app.get("/api/projects")
def projects():
    return PROJECTS


@app.post("/api/contact", status_code=201)
def create_contact(payload: ContactMessage):
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise HTTPException(status_code=503, detail="La base de datos no está configurada.")

    try:
        with closing(psycopg.connect(database_url)) as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO contact_messages (name, email, message) VALUES (%s, %s, %s) RETURNING id",
                    (payload.name, str(payload.email), payload.message),
                )
                message_id = cursor.fetchone()[0]
            connection.commit()
    except psycopg.Error as error:
        raise HTTPException(status_code=503, detail="No se pudo guardar el mensaje.") from error

    return {"id": message_id, "message": "¡Gracias! Tu mensaje fue enviado."}
