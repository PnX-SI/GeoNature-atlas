FROM python:3.9-bullseye AS build

ENV PIP_ROOT_USER_ACTION=ignore

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip setuptools wheel

FROM build AS build-atlas

WORKDIR /build/
COPY /setup.py .
COPY /requirements.in .
COPY /VERSION .
COPY /MANIFEST.in .
COPY /README.rst .
COPY /LICENSE.txt .
COPY /atlas ./atlas
COPY /atlas/configuration/config.py.sample config.py
RUN python setup.py bdist_wheel

FROM node:alpine AS node

WORKDIR /dist/
COPY  atlas/static/package*.json .
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev


FROM python:3.9-bullseye AS app

RUN apt-get update -qq && apt-get install -y \
  postgresql-client

RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip setuptools wheel

WORKDIR /dist/

ENV PIP_ROOT_USER_ACTION=ignore
RUN --mount=type=cache,target=/root/.cache \
    pip install --upgrade pip setuptools wheel

COPY /atlas/static ./static
COPY /atlas/static/custom ./custom_save
COPY /atlas/templates ./templates
COPY /atlas/translations ./translations
COPY --from=node /dist/node_modules ./static/node_modules


FROM app AS app-pypi

COPY /requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt

COPY --from=build-atlas /build/dist/*.whl .

RUN --mount=type=cache,target=/root/.cache \
    pip install *.whl

COPY --chmod=755 ./docker_startup.sh .
COPY --chmod=755 ./docker_install_atlas_schema.sh .
COPY data ./data


FROM app-pypi AS prod


ENV FLASK_APP=app.app:create_app
ENV ATLAS_SETTINGS=/dist/config/config.py
ENV ATLAS_STATIC_FOLDER=/dist/static
ENV ATLAS_TEMPLATE_FOLDER=/dist/
ENV ATLAS_BABEL_TRANSLATION_DIRECTORIES=/dist/translations

EXPOSE 8080

CMD ["./docker_startup.sh"]
