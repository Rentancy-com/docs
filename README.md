# Lofty Open API Documentation

Lofty Developer API documentation built with [Mintlify](https://mintlify.com). Live at [developer.lofty.com](https://developer.lofty.com).

## Development

```bash
# Install Mintlify CLI
npm i -g mint

# Preview locally
mint dev
```

View at `http://localhost:3000`.

## Sync OpenAPI Spec

The API reference pages are auto-generated from `openapi/openapi.json`. Use the sync script to update from the remote spec:

```bash
# Sync from production (default)
./scripts/sync-openapi.sh

# Sync from staging
./scripts/sync-openapi.sh https://api-stage.lofty.com/v3/api-docs
```

The script automatically:
- Downloads the latest OpenAPI spec
- Removes duplicate array item descriptions
- Removes malformed stringified array examples
- Fixes internal webhook documentation links

After syncing, restart `mint dev` to preview changes (OpenAPI spec is only loaded at startup).

## Publishing

Push to `main` branch to trigger automatic deployment via the Mintlify GitHub integration.

## Project Structure

```
docs.json              # Mintlify configuration (navigation, theme, branding)
openapi/openapi.json   # OpenAPI 3.0.1 spec (auto-synced from API server)
scripts/sync-openapi.sh # Spec sync + auto-fix script
api-reference/         # API endpoint pages (openapi frontmatter)
authentication/        # Auth docs (OAuth 2.0, API Keys, Error Codes)
concepts/              # Core concepts (Leads, Webhooks, etc.)
guides/                # How-to guides (Lead Management, Communication)
cli/                   # Lofty CLI documentation
changelog/             # API changelog by year
```

## Troubleshooting

- **OpenAPI changes not showing**: Restart `mint dev` — spec is loaded once at startup.
- **404 page**: Check that the page is listed in `docs.json` navigation.
- **Build errors**: Run `mint validate` to check for issues.
- **Broken links**: Run `mint broken-links` to scan all internal links.
