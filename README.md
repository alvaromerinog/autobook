# autobook

App to manage the maintenances of your car

## Docker

Images are published to GitHub Container Registry on every `v*` tag:

| Image | Pull |
|-------|------|
| backend | `docker pull ghcr.io/alvaromerinog/autobook-backend:latest` |
| frontend | `docker pull ghcr.io/alvaromerinog/autobook-frontend:latest` |

Tags available for each image: `latest`, `<version>` (e.g. `0.1.0`), `<major>.<minor>` (e.g. `0.1`) and `sha-<short>`.

Run them with the published images:

```bash
task docker/prod          # uses TAG=latest
TAG=0.1.0 task docker/prod
```

The frontend bakes `AUTOBOOK_API_URL` at build time. Set the repository variable
`AUTOBOOK_API_URL` (Settings → Secrets and variables → Actions → Variables) before
tagging a release to point the image at your API.

To publish a new release:

```bash
git tag -a v0.1.0 -m "v0.1.0"
git push origin v0.1.0
```
