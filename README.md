# Helm Charts for TRACE Application Suite

![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Secret Manager](https://img.shields.io/badge/Secret_Manager-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)
![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache_Kafka-231F20?style=for-the-badge&logo=apache-kafka&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Semantic Release](https://img.shields.io/badge/Semantic_Release-494949?style=for-the-badge&logo=semantic-release&logoColor=white)
![Cert Manager](https://img.shields.io/badge/Cert_Manager-326CE5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Istio](https://img.shields.io/badge/Istio-466BB0?style=for-the-badge&logo=istio&logoColor=white)

This repository contains Helm charts for deploying the complete TRACE Application Suite on a Kubernetes cluster. The suite includes multiple microservices that work together to process, analyze, and provide insights on TRACE survey data.

## Repository Structure

```
helm-charts/
├── api-server/           # API Server Helm chart
├── db-backup-operator/   # Database Backup Operator Helm chart
├── embedding-service/    # Embedding Service Helm chart
├── manifests/            # Kubernetes manifests for ingress, cert-manager, etc.
├── postgresql/           # Bitnami PostgreSQL Helm chart
├── trace-consumer/       # TRACE Consumer Helm chart
├── trace-llm/            # TRACE LLM Helm chart
├── trace-processor/      # TRACE Processor Helm chart
├── .releaserc.json       # Semantic-release configuration
├── Jenkinsfile           # Jenkins pipeline for releases
├── Jenkinsfile.prcheck   # Jenkins pipeline for PR checks
├── Jenkinsfile.commitlint # Jenkins pipeline for commit linting
└── README.md             # This file
```

## Charts Overview

### API Server

The API Server provides RESTful endpoints for managing users, instructors, courses, and trace data. It handles authentication, authorization, and business logic for the TRACE application. The chart includes an init container that runs database migrations from the db-trace-processor repository to set up the required schema.

**Repository**: [api-server](https://github.com/cyse7125-sp25-team03/api-server)

**Features**:
- RESTful API endpoints for TRACE data
- PostgreSQL database integration
- Database migrations via init container
- Authentication and authorization
- Event streaming with Kafka
- Kubernetes-native deployment

### DB Backup Operator

A Kubernetes operator for automating PostgreSQL database schema backups to Google Cloud Storage (GCS).

**Repository**: [db-backup-operator](https://github.com/cyse7125-sp25-team03/db-backup-operator)

**Features**:
- Custom Resource Definition (CRD) for backup configuration
- Automated scheduled backups to GCS
- Comprehensive status tracking
- Self-healing and retry mechanisms
- Google Cloud integration

### Embedding Service

A service for generating and managing vector embeddings for TRACE survey data, enabling semantic search and similarity analysis.

**Repository**: [embedding-service](https://github.com/cyse7125-sp25-team03/embedding-service)

**Features**:
- Transformer-based vector embeddings
- PostgreSQL with pgvector integration
- Batch processing capabilities
- Multi-entity embedding (comments, ratings, instructors, courses)
- Similarity search testing

### PostgreSQL

A Bitnami PostgreSQL chart used for development and testing. In production, PostgreSQL is bootstrapped through the tf-gcp-infra repository.

**Features**:
- Bitnami PostgreSQL deployment
- Persistent volume configuration
- Initialization scripts
- Replication support
- Metrics and monitoring

### TRACE Processor

A service that consumes messages from Kafka, downloads PDF files from Google Cloud Storage, extracts data from these PDFs, and publishes the processed data back to Kafka.

**Repository**: [trace-processor](https://github.com/cyse7125-sp25-team03/trace-processor)

**Features**:
- Kafka consumer integration
- PDF data extraction
- Google Cloud Storage integration
- Health monitoring endpoints
- Structured data processing

### TRACE Consumer

A service that consumes processed trace survey data from Kafka and stores it in a PostgreSQL database.

**Repository**: [trace-consumer](https://github.com/cyse7125-sp25-team03/trace-consumer)

**Features**:
- Kafka consumer for processed survey data
- PostgreSQL data storage
- Idempotent processing
- Data model validation
- Health check endpoints

### TRACE LLM

A Retrieval-Augmented Generation (RAG) service that leverages Google's Gemini AI to provide natural language insights and answers from TRACE survey data.

**Repository**: [trace-llm](https://github.com/cyse7125-sp25-team03/trace-llm)

**Features**:
- Natural language query processing
- Vector similarity search
- Google Gemini AI integration
- Entity recognition
- Customized prompt engineering

## Installation

### Prerequisites

- Kubernetes cluster (GKE recommended)
- Helm 3.0+
- kubectl configured to communicate with your cluster
- Infrastructure set up using [tf-gcp-infra](https://github.com/cyse7125-sp25-team03/tf-gcp-infra)
- Secret Manager set up for automated secrets retrieval
- Access to all required Docker images

### API Server

```bash
# Install the chart
helm install api-server ./api-server -n api-server

# Set up ingress and certificate
cd manifests/
EMAIL="your-email@example.com" envsubst < clusterissuer.yaml | kubectl apply -f -
HOST="api-server.prd.gcp.csyeteam03.xyz" envsubst < ingress.yaml | kubectl apply -f -
```

### DB Backup Operator

```bash
# Install the chart
helm install db-backup-operator ./db-backup-operator -n operator-ns

# Apply the custom resource
kubectl apply -f db-backup-operator/backup-job-cr.yaml
```

### TRACE Processor

```bash
helm install trace-processor ./trace-processor/ -n trace-processor
```

### TRACE Consumer

```bash
helm install trace-consumer ./trace-consumer/ -n trace-consumer
```

### Embedding Service

```bash
helm install embedding-service ./embedding-service/ -n postgres
```

### TRACE LLM

```bash
# Install the chart
helm install trace-llm ./trace-llm/ -n trace-llm

# Set up ingress
cd manifests/
HOST="asktrace.prd.gcp.csyeteam03.xyz" envsubst < ingress-llm.yaml | kubectl apply -f -
```

### PostgreSQL (Development/Testing Only)

```bash
helm install pg ./postgresql/ -n postgres
```

## Monitoring and Verification

After deploying the charts, verify that all pods are running:

```bash
kubectl get pods -n api-server
kubectl get pods -n trace-processor
kubectl get pods -n trace-consumer
kubectl get pods -n postgres
kubectl get pods -n trace-llm
kubectl get pods -n operator-ns
```

## Architecture

The TRACE Application Suite follows a microservices architecture:

1. **API Server**: Provides REST endpoints for client applications and runs database migrations as an init container
2. **TRACE Processor**: Extracts data from PDF files
3. **TRACE Consumer**: Stores processed data in PostgreSQL
4. **Embedding Service**: Generates vector embeddings
5. **TRACE LLM**: Provides natural language interface to the data
6. **DB Backup Operator**: Ensures data is backed up regularly

Data flows through the system using Kafka as a message broker, and all components are deployed as independent microservices on Kubernetes. The database schema required by all components is automatically set up by migration scripts from the [db-trace-processor](https://github.com/cyse7125-sp25-team03/db-trace-processor) repository, which run as an init container in the API Server deployment.

## Release Process

This repository uses semantic-release to automate versioning and package publishing:

1. When a pull request is merged into the main branch, the semantic-release bot:
   - Updates the Chart.yaml version in the respective charts
   - Generates and publishes Helm package artifacts
   - Pushes changes back to the repository

2. The process is triggered via Jenkins, which runs jobs defined in:
   - `.releaserc.json` → Configures release automation
   - `Jenkinsfile` → Triggers the semantic-release process
   - `Jenkinsfile.prcheck` → Validates Helm templates and linting
   - `Jenkinsfile.commitlint` → Ensures commit messages follow Conventional Commits format

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Google Cloud Secret Manager](https://cloud.google.com/secret-manager)
- [Semantic-Release Docs](https://semantic-release.gitbook.io/semantic-release/)
- [Bitnami PostgreSQL Chart](https://bitnami.com/stack/postgresql/helm)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.