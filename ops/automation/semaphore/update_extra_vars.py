#!/usr/bin/env python3

import json
import requests
from pathlib import Path

# ===== CONFIG =====
SEMA_URL = "http://semaphore_url"
API_TOKEN = "Your_token"
PROJECT_ID = 1
ENV_FILE = "env.json"

HEADERS = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json",
}

# ===== INPUT =====
env_name = input("Please enter your env group name: ").strip()

# ===== LOAD ENV JSON =====
try:
    env_json = json.loads(Path(ENV_FILE).read_text())
except Exception as e:
    print(f"❌ Failed to read {ENV_FILE}: {e}")
    exit(1)

env_json_str = json.dumps(env_json)

print(f"Searching for: {env_name}")

# ===== FETCH ENV LIST =====
try:
    resp = requests.get(
        f"{SEMA_URL}/api/project/{PROJECT_ID}/environment",
        headers=HEADERS,
        timeout=30,
    )
    resp.raise_for_status()
    env_list = resp.json()
except Exception as e:
    print(f"❌ Failed to fetch environments: {e}")
    exit(1)

# ===== FIND ENV ID =====
env_id = None
for env in env_list:
    if env.get("name") == env_name:
        env_id = env.get("id")
        break

# ===== PAYLOAD BUILDERS =====
def build_new_payload():
    return {
        "name": env_name,
        "project_id": PROJECT_ID,
        "env": "{}",
        "json": env_json_str,
        "secrets": None,
    }


def build_update_payload(env_id):
    return {
        "id": int(env_id),
        "name": env_name,
        "project_id": PROJECT_ID,
        "env": "{}",
        "json": env_json_str,
        "secrets": None,
    }


# ===== CREATE OR UPDATE =====
try:
    if not env_id:
        print(f"{env_name} does not exist. Adding it to the variable group...")

        response = requests.post(
            f"{SEMA_URL}/api/project/{PROJECT_ID}/environment",
            headers=HEADERS,
            json=build_new_payload(),
            timeout=30,
        )

    else:
        print(f"ENV ID for {env_name}: {env_id}")
        print("Updating the ENV...")

        response = requests.put(
            f"{SEMA_URL}/api/project/{PROJECT_ID}/environment/{env_id}",
            headers=HEADERS,
            json=build_update_payload(env_id),
            timeout=30,
        )

    response.raise_for_status()
    print("✅ Operation successful")

except Exception as e:
    print(f"❌ API operation failed: {e}")
    exit(1)

# ===== PRINT ENV NAMES =====
print("\nAvailable environment groups:")
for env in env_list:
    print(f"- {env.get('name')}")