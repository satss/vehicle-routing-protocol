FROM ghcr.io/astral-sh/uv:0.10.3@sha256:7a88d4c4e6f44200575000638453a5a381db0ae31ad5c3a51b14f8687c9d93a3 AS uv

FROM mcr.microsoft.com/devcontainers/python:1-3.13-bookworm@sha256:0aa711e570b306c02946cdda67587ce8c65978dbb65691341cbcfd4854dfcfff

# The base image currently includes a Yarn apt source with an unavailable
# signing key. Devcontainer features run apt-get update during install, so we
# remove that source to keep builds reproducible.
RUN rm -f /etc/apt/sources.list.d/yarn.list

COPY --from=uv /uv /uvx /bin/