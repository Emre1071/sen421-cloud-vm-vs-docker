"""Benchmark API shared by the VM and the container.

/health and /payload are frozen at import so those routes do not time JSON
encoding. /compute hashes on every call; caching that digest would erase the
CPU measurement.
"""

import hashlib

from fastapi import FastAPI
from fastapi.responses import Response

_HEALTH = b'{ "status": "ok" }'
_PAYLOAD_BYTES = 64 * 1024
_COMPUTE_ITERATIONS = 50_000

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)


def _build_payload(size: int) -> bytes:
    head = b'{"size":65536,"data":"'
    tail = b'"}'
    fill = size - len(head) - len(tail)
    if fill < 0:
        raise RuntimeError("64 KiB frame is smaller than the JSON envelope")
    body = head + (b"a" * fill) + tail
    if len(body) != size:
        raise RuntimeError("payload is not 64 KiB")
    return body


_PAYLOAD = _build_payload(_PAYLOAD_BYTES)


def _compute_body() -> bytes:
    digest = hashlib.sha256(b"topic2").digest()
    for i in range(_COMPUTE_ITERATIONS):
        digest = hashlib.sha256(digest + i.to_bytes(4, "little")).digest()
    return b'{"iterations":50000,"digest":"' + digest.hex().encode("ascii") + b'"}'


@app.get("/health")
def health() -> Response:
    return Response(content=_HEALTH, media_type="application/json")


@app.get("/compute")
def compute() -> Response:
    return Response(content=_compute_body(), media_type="application/json")


@app.get("/payload")
def payload() -> Response:
    return Response(content=_PAYLOAD, media_type="application/json")
