FROM python:3.11.9-bookworm AS build

ENV PIP_ROOT_USER_ACTION=ignore

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip build

WORKDIR /build/

COPY /atlas ./atlas
COPY /atlas/configuration/config.py.sample ./atlas/configuration/config.py
COPY /LICENSE.txt .
COPY /MANIFEST.in .
COPY /pyproject.toml .
COPY /README.rst .
COPY /requirements.in .
COPY /pyproject.toml .
COPY /VERSION .
RUN python -m build


FROM node:alpine AS node

WORKDIR /dist/

COPY /atlas/static/package*.json .
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev


FROM python:3.11.9-bookworm AS app

ENV PIP_ROOT_USER_ACTION=ignore

RUN apt-get update -qq && apt-get install -y \
  postgresql-client

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip setuptools wheel

WORKDIR /dist/

COPY /atlas/configuration/config.py.* ./atlas/configuration/
COPY /atlas/static ./atlas/static
COPY /atlas/templates ./atlas/templates
COPY /atlas/translations ./atlas/translations
COPY --from=node /dist/node_modules ./atlas/static/node_modules


FROM app AS app-pypi

COPY /requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt

COPY --from=build /build/dist/*.whl .
RUN --mount=type=cache,target=/root/.cache \
    pip install --no-deps *.whl

WORKDIR /dist/

COPY data ./data

COPY --chmod=755 ./docker_startup.sh .
COPY --chmod=755 ./install_app.sh .
COPY --chmod=755 ./install_db.sh .
COPY --chmod=755 ./utils.bash .


FROM app-pypi AS prod

# Production environment variables for Flask/Atlas
# If you change Atlas directories for config.py, static/, templates/ or translations/,
# you must also change them here or in your own Dockerfile.
ENV FLASK_APP=app.app:create_app
ENV ATLAS_SETTINGS=/dist/atlas/configuration/config.py
ENV ATLAS_STATIC_FOLDER=/dist/atlas/static
# WARNING: ATLAS_TEMPLATE_FOLDER must indicate the parent folder of the templates/ folder !
ENV ATLAS_TEMPLATE_FOLDER=/dist/atlas/
ENV ATLAS_BABEL_TRANSLATION_DIRECTORIES=/dist/atlas/translations

EXPOSE 8080

CMD ["./docker_startup.sh"]
