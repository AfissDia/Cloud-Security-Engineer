import json
import subprocess
import fnmatch

ENDPOINT = "http://127.0.0.1:4566"
POLICY_ID = "p-b26faf4f"

# Récupération de la politique depuis MiniStack
result = subprocess.run(
    [
        "aws",
        "--endpoint-url", ENDPOINT,
        "organizations",
        "describe-policy",
        "--policy-id", POLICY_ID,
        "--output", "json"
    ],
    capture_output=True,
    text=True,
    check=True
)

response = json.loads(result.stdout)
policy = json.loads(response["Policy"]["Content"])


def is_denied(action):
    """Vérifie si une action correspond à un Deny explicite."""

    for statement in policy["Statement"]:

        if statement["Effect"] != "Deny":
            continue

        if statement.get("Resource") != "*":
            continue

        actions = statement.get("Action", [])

        if isinstance(actions, str):
            actions = [actions]

        for pattern in actions:
            if fnmatch.fnmatchcase(
                action.lower(),
                pattern.lower()
            ):
                return True

    return False


# Scénarios de test
tests = {
    "cloudtrail:StopLogging": True,
    "cloudtrail:DeleteTrail": True,
    "cloudtrail:UpdateTrail": True,
    "organizations:LeaveOrganization": True,
    "s3:ListAllMyBuckets": False
}

print("\n=== TESTS SCP DATAHELIX ===\n")

success = 0

for action, expected in tests.items():

    actual = is_denied(action)

    if actual == expected:
        status = "PASS"
        success += 1
    else:
        status = "FAIL"

    decision = "DENY" if actual else "NO EXPLICIT DENY"

    print(f"[{status}] {action} -> {decision}")

print(f"\nRésultat : {success}/{len(tests)} tests réussis")

if success != len(tests):
    raise SystemExit(1)
