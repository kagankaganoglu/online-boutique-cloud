#!/usr/bin/env bash
set -e

# Deploy emailservice (HTTP/1.1)
gcloud run deploy emailservice \
  --image=gcr.io/newproject-460615/emailservice:latest \
  --platform=managed --region=us-central1 \
  --allow-unauthenticated --port=8080 --use-http2

# Deploy paymentservice (gRPC)
gcloud run deploy paymentservice \
  --image=gcr.io/newproject-460615/paymentservice:latest \
  --platform=managed --region=us-central1 \
  --allow-unauthenticated --port=50051 --use-http2
