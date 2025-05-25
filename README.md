# Online Boutique: Hybrid Cloud Deployment & Performance Testing

This repository demonstrates a hybrid cloud deployment of Google's Online Boutique microservices demo, split across GKE, Cloud Run, and a Compute Engine VM, plus a Locust-based performance testing suite.

---

## Overview

- **GKE (Kubernetes)**
  - Frontend, cartservice, checkoutservice, currencyservice, productcatalogservice, recommendationservice, shippingservice
- **Cloud Run (serverless)**
  - paymentservice, emailservice
- **Compute Engine VM**
  - Redis (stateful store)
- **Performance Testing**
  - Locust scripts in `/locust` simulate realistic user behavior against the public frontend

---

## 🔧 Prerequisites

- Google Cloud SDK (`gcloud`)
- Docker
- A GCP project (`newproject-460615`)
- Billing enabled, APIs enabled: GKE, Cloud Run, Compute Engine, Container Registry
- `kubectl` configured for your GKE cluster

---

## 🚀 Deployment

### 1. Build & Push Docker Images

```bash
# From repo root
docker build -t gcr.io/newproject-460615/frontend ./src/frontend
docker build -t gcr.io/newproject-460615/cartservice ./src/cartservice
# … repeat for each GKE service …

docker build -t gcr.io/newproject-460615/paymentservice ./src/paymentservice
docker build -t gcr.io/newproject-460615/emailservice ./src/emailservice

# Push all images
docker push gcr.io/newproject-460615/frontend
docker push gcr.io/newproject-460615/cartservice
# …
docker push gcr.io/newproject-460615/paymentservice
docker push gcr.io/newproject-460615/emailservice
```

### 2. Deploy to GKE

```bash
# Authenticate
gcloud container clusters get-credentials boutique-gke --zone us-central1-a --project newproject-460615

# Example for frontend
kubectl create deployment frontend --image=gcr.io/newproject-460615/frontend
kubectl expose deployment frontend --port=80 --target-port=8080 --type=LoadBalancer

# Repeat for all GKE services
kubectl create deployment cartservice --image=gcr.io/newproject-460615/cartservice
kubectl expose deployment cartservice --port=80 --target-port=8080 --type=ClusterIP
# …and so on
```

> **Note**: Set any required environment variables (for example, `PAYMENT_SERVICE_ADDR`) with `kubectl set env`.

### 3. Deploy Redis on VM

1. Create a VM in Compute Engine with a static internal IP (for example, `10.10.5.10`).
2. SSH in and install Redis:
   ```bash
   sudo apt update
   sudo apt install -y redis-server
   ```
3. Ensure the VM's firewall allows port `6379` only from your VPC or GKE.

### 4. Deploy to Cloud Run

```bash
gcloud run deploy paymentservice   --image gcr.io/newproject-460615/paymentservice   --region us-central1   --allow-unauthenticated

gcloud run deploy emailservice   --image gcr.io/newproject-460615/emailservice   --region us-central1   --allow-unauthenticated
```

After deployment, note each Service URL (for example, `https://payment-XXX-uc.a.run.app`).

---

## 🧪 Performance Testing with Locust

Testing scripts live in `/locust`.

### Setup

```bash
cd locust
python3 -m venv locust-env
source locust-env/bin/activate
pip install -r requirements.txt   # contains: locust
```

### `locustfile.py`

```python
from locust import HttpUser, task, between

class WebsiteUser(HttpUser):
    wait_time = between(1, 5)

    @task(4)
    def load_homepage(self):
        self.client.get("/")

    @task(3)
    def view_cart(self):
        self.client.get("/cart")

    @task(2)
    def checkout(self):
        self.client.get("/cart/checkout")

    @task(1)
    def view_product(self):
        self.client.get("/product/OLJCESPC7Z")
```

## 📈 Experiment Design

### System Parameters (Independent Variables)

- **Kubernetes Replicas** (for example, frontend: 1, 2, 4 pods)
- **GKE CPU/Memory Limits** (for example, `cpu=250m→500m`)
- **Number of Locust Users** (set to 100)
- **Spawn Rate** (set to 10 users per second)
- **Task Weights** (for example, homepage vs. checkout)

### Metrics Collected (Dependent Variables)

- **Request Latency** (average, p95)
- **Throughput** (requests per second)
- **Error Rate** (percentage of failed requests)

---

## Useful Commands

```bash
kubectl get pods,svc,deploy
kubectl top pods
gcloud run services list --region us-central1
gcloud compute instances list
```

