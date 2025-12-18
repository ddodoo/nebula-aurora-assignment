# User and Post API (Kubernetes Deployment)

A FastAPI-based service for managing users and posts, deployed on a local Kubernetes cluster (k3d) using Helm, with PostgreSQL, Prometheus, and Grafana.

## ✨ Features

- Create and retrieve users

- Create and retrieve posts

- Async database operations using SQLAlchemy + asyncpg

- PostgreSQL database (Kubernetes StatefulSet)

- Prometheus metrics exposed at /metrics

- Grafana dashboards for observability

- Kubernetes-native deployment via Helm

- Ingress-based routing using Traefik

- Local LoadBalancer access via k3d

## 🧱 Architecture Overview

```
Host (localhost:8080)
        │
        ▼
k3d LoadBalancer (Traefik)
        │
        ├── /users, /posts, /docs, /metrics → FastAPI
        └── /grafana                       → Grafana
```

## 📦 Project Structure

```
.
├── Dockerfile # Cluster bootstrap container
├── README.md
├── run_cluster.sh # Creates k3d cluster with LB
├── wiki-chart # Helm chart
│   ├── Chart.yaml
│   ├── templates
│   │   ├── deployment.yaml # FastAPI
│   │   ├── grafana-dashboard-configmap.yaml
│   │   ├── grafana-datasource-configmap.yaml
│   │   ├── grafana-deployment.yaml
│   │   ├── grafana-service.yaml
│   │   ├── ingress.yaml # Traefik ingress
│   │   ├── postgres-service.yaml
│   │   ├── postgres-statefulset.yaml
│   │   ├── prometheus-deployment.yaml
│   │   ├── prometheus-service.yaml
│   │   └── service.yaml # FastAPI service
│   └── values.yaml
└── wiki-service
    ├── app
    │   ├── database.py
    │   ├── __init__.py
    │   ├── main.py
    │   ├── metrics.py
    │   ├── models.py
    │   ├── __pycache__
    │   │   ├── database.cpython-313.pyc
    │   │   ├── __init__.cpython-313.pyc
    │   │   ├── main.cpython-313.pyc
    │   │   ├── metrics.cpython-313.pyc
    │   │   ├── models.cpython-313.pyc
    │   │   └── schemas.cpython-313.pyc
    │   ├── pyproject.toml
    │   ├── README.md
    │   ├── schemas.py
    │   ├── test_api.sh
    │   └── uv.lock
    ├── Dockerfile  # FastAPI image
    └── pyproject.toml
```

## 🚀 Running the Project (Local)
1️⃣ Build the cluster image

```
docker build -t wiki-cluster-image .
```

2️⃣ Run the cluster container

```
docker run -p 8080:8080 wiki-cluster-image
```

This will:

- Create a k3d cluster

- Install Traefik

- Deploy the Helm chart

- Expose services via LoadBalancer


## 🌍 Accessing the Services (From Host)
```
Service	URL
FastAPI Docs	http://localhost:8080/docs

FastAPI Metrics	http://localhost:8080/metrics

Grafana	http://localhost:8080/grafana

Prometheus	Internal (scrapes /metrics)
```

## 📘 API Documentation

Swagger UI is available at:
```
http://localhost:8080/docs
```

## 🔌 API Endpoints
POST /users

Create a new user.
```
{
  "name": "John Doe"
}

GET /users/{id}
```

Fetch a user by ID.

POST /posts

Create a post for a user.
```
{
  "user_id": 1,
  "content": "Hello, World!"
}
```

GET /posts/{id}

Fetch a post by ID.

## 📊 Metrics

The service exposes Prometheus metrics at:

/metrics

Exposed Metrics

`users_created_total`
`posts_created_total`

Python process and GC metrics

Example:

`curl http://localhost:8080/metrics`

📈 Grafana

Grafana is exposed under a subpath using Traefik middleware:

`http://localhost:8080/grafana`


Default credentials (from values.yaml):
```
Username: admin
Password: admin
```

Grafana is preconfigured to use Prometheus as a datasource.

## 🧠 Notes on Ingress & Routing

FastAPI natively supports /docs and /metrics, so no StripPrefix is required

Grafana does not support subpaths by default

A Traefik StripPrefix middleware is used for /grafana

Ingress and middleware are namespace-scoped (wiki)

## 🛠 Technologies Used

- FastAPI
- SQLAlchemy (async)
- PostgreSQL
- Prometheus
- Grafana
- Docker
- Kubernetes (k3s via k3d)
- Helm
- Traefik Ingress Controller

✅ Status

✔ API reachable from host
✔ Database auto-initialized
✔ Metrics exposed and scraped
✔ Grafana accessible via ingress
✔ No port-forwarding required