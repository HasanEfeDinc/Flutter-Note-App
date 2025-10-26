import uuid
from datetime import datetime, timezone
from typing import Tuple, Optional, Dict, Any

from flask import Flask, request, jsonify
from flask_cors import CORS

import firebase_admin
from firebase_admin import auth, credentials
from firebase_admin import firestore as fa_firestore


SERVICE_ACCOUNT_PATH = "serviceAccountKey.json"
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)
db = fa_firestore.client()


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()

def _require_auth() -> Tuple[Optional[str], Optional[Tuple[str, int]]]:
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return None, ("Missing/invalid Authorization header", 401)
    id_token = auth_header.split(" ", 1)[1].strip()
    try:
        decoded = auth.verify_id_token(id_token)
        return decoded["uid"], None
    except Exception as e:
        return None, (f"Invalid token: {e}", 401)

def _user_notes_ref(uid: str):
    return db.collection("users").document(uid).collection("notes")

def _normalize_note_payload(j: Dict[str, Any]) -> Dict[str, Any]:
    note_id = j.get("id") or uuid.uuid4().hex
    title = (j.get("title") or "New Note").strip() or "New Note"
    content = (j.get("content") or "No additional text")
    pinned = bool(j.get("pinned", False))
    pinned_at = j.get("pinnedAt")  # ISO str veya None
    created_at = j.get("createdAt") or _now_iso()

    return {
        "id": note_id,
        "title": title,
        "content": content,
        "pinned": pinned,
        "pinnedAt": pinned_at,
        "createdAt": created_at,
    }

def _note_to_json(doc_snap) -> Dict[str, Any]:
    d = doc_snap.to_dict() or {}
    return {
        "id": d.get("id") or doc_snap.id,
        "title": d.get("title", "New Note"),
        "content": d.get("content", "No additional text"),
        "createdAt": d.get("createdAt", _now_iso()),
        "pinned": bool(d.get("pinned", False)),
        "pinnedAt": d.get("pinnedAt"),
    }

@app.get("/notes")
def list_notes():
    uid, err = _require_auth()
    if err:
        return err

    docs = _user_notes_ref(uid).stream()
    items = [_note_to_json(d) for d in docs]

    def sort_key(x):
        return (
            1 if x.get("pinned") else 0,
            x.get("pinnedAt") or "",
            x.get("createdAt") or "",
        )

    items.sort(key=sort_key, reverse=True)
    return jsonify(items), 200


@app.post("/notes")
def create_note():
    uid, err = _require_auth()
    if err:
        return err

    body = request.get_json(force=True) or {}
    payload = _normalize_note_payload(body)

    ref = _user_notes_ref(uid).document(payload["id"])
    ref.set(payload)

    return jsonify(payload), 201


@app.put("/notes/<note_id>")
def update_note(note_id: str):
    uid, err = _require_auth()
    if err:
        return err

    body = request.get_json(force=True) or {}
    ref = _user_notes_ref(uid).document(note_id)
    snap = ref.get()
    if not snap.exists:
        return ("Not found", 404)

    allowed = {k: body[k] for k in ["title", "content", "pinned", "pinnedAt"] if k in body}
    if allowed:
        ref.update(allowed)

    return jsonify(_note_to_json(ref.get())), 200


@app.delete("/notes/<note_id>")
def delete_note(note_id: str):
    uid, err = _require_auth()
    if err:
        return err

    ref = _user_notes_ref(uid).document(note_id)
    if not ref.get().exists:
        return ("Not found", 404)

    ref.delete()
    return ("", 204)

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8000, debug=True)
