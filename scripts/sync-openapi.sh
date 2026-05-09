#!/bin/bash
# Sync OpenAPI spec from remote and apply fixes
# Usage: ./scripts/sync-openapi.sh

set -e

SPEC_URL="${1:-https://api.lofty.com/v3/api-docs}"
SPEC_FILE="openapi/openapi.json"

echo "Downloading spec from $SPEC_URL..."
curl -s "$SPEC_URL" -o "$SPEC_FILE"
echo "Downloaded $(wc -c < "$SPEC_FILE") bytes"

echo "Applying fixes..."
python3 << 'PYEOF'
import json

with open("openapi/openapi.json") as f:
    spec = json.load(f)

fixes = 0

# Fix 1: Remove duplicate descriptions in array items
for schema_name, schema in spec.get("components", {}).get("schemas", {}).items():
    for fname, fval in schema.get("properties", {}).items():
        if fval.get("type") == "array" and "items" in fval:
            items = fval["items"]
            parent_desc = fval.get("description", "")
            items_desc = items.get("description", "")
            if parent_desc and items_desc and (
                parent_desc == items_desc or
                items_desc in parent_desc or
                parent_desc in items_desc
            ):
                items.pop("description", None)
                fixes += 1
            # Remove malformed stringified array examples
            items_example = items.get("example", "")
            if isinstance(items_example, str) and items_example.startswith("["):
                items.pop("example", None)
                fixes += 1

# Fix 2: Fix webhook links
for tag in spec.get("tags", []):
    desc = tag.get("description", "")
    if "/docs/webhook-event-payloads" in desc:
        tag["description"] = desc.replace(
            "[Webhook Event Payloads](/docs/webhook-event-payloads)",
            "[Webhook Event Payloads](/concepts/webhooks#event-payloads)"
        )
        fixes += 1

for path in ["/v1.0/webhooks", "/v1.0/webhook"]:
    if path in spec["paths"]:
        for m, op in spec["paths"][path].items():
            if isinstance(op, dict) and "/docs/webhook-event-payloads" in op.get("description", ""):
                op["description"] = op["description"].replace(
                    "[Webhook Event Payloads](/docs/webhook-event-payloads)",
                    "[Webhook Event Payloads](/concepts/webhooks#event-payloads)"
                )
                fixes += 1

with open("openapi/openapi.json", "w") as f:
    json.dump(spec, f, indent=2, ensure_ascii=False)

print(f"Applied {fixes} fixes")
PYEOF

echo "Done. Run 'mint dev' to preview changes."
