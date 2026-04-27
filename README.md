# vehicle-routing-protocol
This is just for playing around with vrp

# formatter and linter
 - ruff check --fix  
 - ruff format

## Development Environment
For the development environment we define a devcontainer in `.devcontainer`.

### Local Nominatim setup
The devcontainer starts a local Nominatim instance automatically through `.devcontainer/post_start.sh`.

The service is exposed on `localhost:8080` and uses this NRW-only OpenStreetMap extract:
`https://download.geofabrik.de/europe/germany/nordrhein-westfalen-latest.osm.pbf`

On the first startup, Nominatim downloads and imports the NRW extract into a local Docker volume. This can take a while depending on machine resources. Later restarts are much faster because the imported data is reused.

Check service health:

```bash
curl -fsS "http://localhost:8080/status?format=json"
```

Run a smoke-test geocode query (example NRW address):

```bash
curl -fsS "http://localhost:8080/search?q=Post+Tower&format=jsonv2&limit=1"
```

If the first startup fails because the data download or import was interrupted, retry with:

```bash
docker compose -f .devcontainer/docker-compose.location-services.yml up -d nominatim && docker logs -f local-nominatim
```

Reset local Nominatim data and force a fresh import:

```bash
docker compose -f .devcontainer/docker-compose.location-services.yml down -v && docker compose -f .devcontainer/docker-compose.location-services.yml up -d nominatim
```

If logs show `planet_osm_nodes - error on COPY: server closed the connection unexpectedly` during import, the local Docker runtime is likely under memory pressure. This repository defaults Nominatim import to a single thread to reduce memory usage. After updating your branch, restart with:

```bash
docker compose -f .devcontainer/docker-compose.location-services.yml down -v && docker compose -f .devcontainer/docker-compose.location-services.yml up -d nominatim && docker logs -f local-nominatim
```

### Local Valhalla setup
The devcontainer also starts a local Valhalla instance automatically through `.devcontainer/post_start.sh`.

The service is exposed on `localhost:8002` and uses the same NRW-only OpenStreetMap extract as Nominatim:
`https://download.geofabrik.de/europe/germany/nordrhein-westfalen-latest.osm.pbf`

Valhalla data is persisted in `infra/valhalla/custom_files/`, which is mounted as `/custom_files` in the container. On first startup, the script downloads the NRW PBF into this directory if missing, then Valhalla builds routing artifacts there. The compose service also sets `tile_urls` to the same NRW extract as a compatibility fallback for the scripted image startup.

Check service health:

```bash
curl -fsS "http://localhost:8002/status"
```

Run a route smoke test (Cologne to Dusseldorf):

```bash
curl -fsS -X POST "http://localhost:8002/route" -H "Content-Type: application/json" -d '{"locations":[{"lat":50.9413,"lon":6.9583},{"lat":51.2277,"lon":6.7735}],"costing":"auto"}'
```

Run a square matrix smoke test for VRP inputs:

```bash
curl -fsS -X POST "http://localhost:8002/sources_to_targets" -H "Content-Type: application/json" -d '{"sources":[{"lat":50.9413,"lon":6.9583},{"lat":51.2277,"lon":6.7735},{"lat":51.9607,"lon":7.6261}],"targets":[{"lat":50.9413,"lon":6.9583},{"lat":51.2277,"lon":6.7735},{"lat":51.9607,"lon":7.6261}],"costing":"auto"}'
```

If Valhalla startup fails, retry and follow logs with:

```bash
docker compose -f .devcontainer/docker-compose.location-services.yml up -d valhalla && docker logs -f local-valhalla
```

Reset local Valhalla data and force a fresh NRW tile build:

```bash
rm -rf infra/valhalla/custom_files/* && touch infra/valhalla/custom_files/.gitkeep && docker compose -f .devcontainer/docker-compose.location-services.yml up -d valhalla
```