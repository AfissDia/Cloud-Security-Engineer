#!/usr/bin/env python3
import json
import sys
from pathlib import Path

RULES = {
    "StopLogging": ("DET-001", "CRITICAL", "Arrêt de CloudTrail"),
    "DeleteTrail": ("DET-001", "CRITICAL", "Suppression de CloudTrail"),
    "UpdateTrail": ("DET-001", "CRITICAL", "Modification de CloudTrail"),
    "CreatePolicy": ("DET-002", "HIGH", "Création d'une politique Organizations"),
    "UpdatePolicy": ("DET-002", "HIGH", "Modification d'une politique SCP"),
    "DeletePolicy": ("DET-002", "HIGH", "Suppression d'une politique SCP"),
    "AttachPolicy": ("DET-002", "HIGH", "Rattachement d'une politique"),
    "DetachPolicy": ("DET-002", "HIGH", "Détachement d'une politique"),
    "DeletePublicAccessBlock": ("DET-003", "HIGH", "Suppression du blocage public S3"),
    "PutBucketPublicAccessBlock": ("DET-003", "HIGH", "Modification du blocage public S3"),
    "DeleteBucketEncryption": ("DET-003", "HIGH", "Suppression du chiffrement S3"),
}

def detect(event):
    name = event.get("EventName", "")
    if name not in RULES:
        return None

    rule_id, severity, description = RULES[name]

    return {
        "rule_id": rule_id,
        "severity": severity,
        "event_name": name,
        "description": description,
        "account": event.get("Username", "unknown"),
        "time": event.get("EventTime", "unknown"),
    }

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 detect_cloudtrail.py <events.json>")
        sys.exit(1)

    path = Path(sys.argv[1])
    data = json.loads(path.read_text(encoding="utf-8"))

    events = data.get("Events", [])
    alerts = []

    for event in events:
        alert = detect(event)
        if alert:
            alerts.append(alert)

    print(f"Événements analysés : {len(events)}")
    print(f"Alertes générées : {len(alerts)}")

    for alert in alerts:
        print(
            f"[{alert['severity']}] {alert['rule_id']} "
            f"- {alert['event_name']} "
            f"- Compte : {alert['account']}"
        )

    print("\nRésultats enregistrés dans evidence/detection/alerts.json")

    output = Path("evidence/detection/alerts.json")
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps({"alerts": alerts}, indent=2),
        encoding="utf-8"
    )

if __name__ == "__main__":
    main()
