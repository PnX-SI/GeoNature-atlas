###############################################
# 1) BUILD : app wheel
###############################################
FROM python:3.11.9-bookworm AS build

ENV PIP_ROOT_USER_ACTION=ignore

WORKDIR /build/

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip build

COPY LICENSE.txt MANIFEST.in pyproject.toml README.rst requirements.in VERSION ./
RUN python -m build



###############################################
# 2) NODE : frontend dependancies
###############################################
FROM node:alpine AS node

WORKDIR /build/

COPY atlas/static/package*.json .
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev



###############################################
# 3) BASE : common env (Python + postgresql + assets)
###############################################
FROM python:3.11.9-bookworm AS base

ENV PIP_ROOT_USER_ACTION=ignore

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

WORKDIR /dist/

# Copie des assets, data et configuration
COPY data data
COPY atlas/configuration atlas/configuration
COPY atlas/static atlas/static
COPY atlas/templates atlas/templates
COPY atlas/translations atlas/translations
COPY --from=node /build/node_modules atlas/static/node_modules

# Copie des scripts d’installation
COPY install install
RUN cp atlas/configuration/settings.ini.sample atlas/configuration/settings.ini
RUN chmod +x install/install_app.sh
RUN ./install/install_app.sh --docker


ENV ATLAS_SETTINGS=/dist/atlas/configuration/config.py
ENV ATLAS_STATIC_FOLDER=/dist/atlas/static
# WARNING: ATLAS_TEMPLATE_FOLDER must indicate the parent folder of the templates/ folder !
ENV ATLAS_TEMPLATE_FOLDER=/dist/atlas/
ENV ATLAS_BABEL_TRANSLATION_DIRECTORIES=/dist/atlas/translations;/dist/atlas/static/custom;



###############################################
# 4) PREPROD : code source + gunicorn
###############################################
FROM base AS preprod

WORKDIR /dist/

COPY . .

RUN --mount=type=cache,target=/root/.cache \ 
    pip install -e ".[dev]"


ENV FLASK_ENV=production

EXPOSE 8080
CMD ["gunicorn", "-b", "0.0.0.0:8080", "atlas.app:create_app()"]



###############################################
# 5) PROD : wheels uniquement + gunicorn
###############################################
FROM base AS prod

WORKDIR /dist/

COPY --from=build /build/dist/*.whl .
RUN --mount=type=cache,target=/root/.cache \
    pip install --no-deps *.whl

COPY atlas atlas

ENV FLASK_ENV=production

EXPOSE 8080
CMD ["gunicorn", "-b", "0.0.0.0:8080", "atlas.app:create_app()"]



###############################################
# 6) DEV : code source + flask debug
###############################################
FROM base AS dev

WORKDIR /dist/

COPY . .

RUN --mount=type=cache,target=/root/.cache \
    pip install -e ".[dev]"


ENV FLASK_APP=app.app:create_app
ENV FLASK_DEBUG=1

EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]