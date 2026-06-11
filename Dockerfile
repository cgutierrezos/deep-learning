FROM nvidia/cuda:12.3.2-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

# Añadir deadsnakes PPA — ppa.launchpadcontent.net es accesible desde Docker Desktop
# trusted=yes evita la verificación GPG que falla en entornos con red restringida
RUN echo "deb [trusted=yes] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" \
    > /etc/apt/sources.list.d/deadsnakes.list

RUN apt-get update \
    && apt-get install -y python3.12 python3.12-dev python3.12-venv ca-certificates git unzip \
    && rm -rf /var/lib/apt/lists/*

# Virtualenv evita restricciones PEP 668 de Ubuntu
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /workspace

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Dependencias runtime para OpenCV (cv2).
# Se dejan al final para validar este cambio reconstruyendo solo la ultima capa.
RUN apt-get update \
    && apt-get install -y libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 \
    && rm -rf /var/lib/apt/lists/*