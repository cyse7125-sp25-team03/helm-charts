# Helm Charts for API Server Deployment

This repository contains Helm charts for deploying the **API Server**, **Bitnami PostgreSQL**, **TRACE Processor**, **TRACE Consumer**, **Embedding Service** and **TRACE LLM** on a Kubernetes cluster. The API Server is part of the **TRACE Application** and requires a PostgreSQL database for operation.  

## Repository Structure  

```
./postgres/                 # Bitnami PostgreSQL Helm chart
./api-server/               # API Server Helm chart
  ├── Chart.yaml            # Helm chart metadata
  ├── values.yaml           # Default configuration values
  ├── .sops.yaml            # SOPS configuration for secrets
  ├── secrets.enc.yaml.enc  # Encrypted secrets file
  ├── .helmignore           # Helm ignore file
  ├── templates/            # Helm templates
      ├── _helpers.tpl      # Helper functions
      ├── configmap.yaml    # ConfigMap definition
      ├── deployment.yaml   # Deployment definition
      ├── networkpolicy.yaml # Network policies
      ├── secrets.yaml      # Secret management
      ├── service.yaml      # Service definition
      ├── serviceaccount.yaml # Service account
./.releaserc.json           # Semantic-release configuration
./Jenkinsfile               # Triggers semantic-release job
./Jenkinsfile.prcheck       # Runs Helm lint and template checks
./Jenkinsfile.commitlint    # Checks conventional commits
package.json                # Semantic-release dependencies
package-lock.json           # Locked dependency versions
```

## Deployment Steps  

### 1. Encrypt Secrets Locally with SOPS  

Before deploying the API Server, create an encrypted secrets file.  

**Create `secrets.enc.yaml` with the following content:**  

```yaml
apiServer:
  postgres:
    username: "your_username"
    password: "your_password"
  serviceAccount:
    gsaEmail: "your_service_account_email"
```

**Encrypt using SOPS:**  

```sh
sops --encrypt --input-type yaml --output-type yaml secrets.enc.yaml > secrets.enc.yaml.enc
```

---

### 2. Install Dependencies on Cluster  

**Install Helm and Helm-Secrets Plugin:**  

```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm plugin install https://github.com/jkroepke/helm-secrets
```

**Install SOPS:**  

```sh
curl -LO https://github.com/getsops/sops/releases/download/v3.9.4/sops-v3.9.4.linux.amd64
sudo mv sops-v3.9.4.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops
```

---

### 3. Create Namespaces  

```sh
kubectl create namespace postgres
kubectl create namespace api-server
```

---

### 4. Install PostgreSQL  

**Build Dependencies:**  

```sh
cd helm-charts/
helm dependency build ./postgresql/
```

**Deploy PostgreSQL:**  

```sh
helm install pg ./postgresql/ -n postgres
```

**Verify Status:**  

```sh
kubectl get pods -n postgres --watch
```

---

### 5. Create DockerHub Secret for API Server  

```sh
kubectl create secret docker-registry dockerhub-secret \
  --docker-username=your_username \
  --docker-password=your_pat \
  --docker-email=your_email -n api-server
```

---

### 6. Deploy API Server  

```sh
helm secrets install api-server ./api-server -n api-server \
 -f ./api-server/values.yaml \
 -f ./api-server/secrets.enc.yaml.enc
```

**Check Pod Status:**  

```sh
kubectl get pods -n api-server --watch
```

---

### 7. Test API Server  

**Port-forward API Server Pod:**  

```sh
kubectl port-forward -n api-server pod/POD_NAME 8080:8080 &
```

**OR, Exec into Pod:**  

```sh
kubectl exec -n api-server -it POD_NAME -- sh
```

---

## Release Process with Semantic-Release  

This repository uses **semantic-release** to automate versioning and package publishing.  

1. When a pull request is merged into the **main** branch, the **semantic-release** bot:
   - Updates the **Chart.yaml** version in the `api-server` chart.
   - Generates and publishes Helm package artifacts.  
   - Pushes changes back to the repository.  

2. The process is triggered via **Jenkins**, which runs jobs defined in:  
   - `.releaserc.json` → Configures release automation.  
   - `Jenkinsfile` → Triggers the **semantic-release** process.  
   - `Jenkinsfile.prcheck` → Validates Helm templates and linting.  
   - `Jenkinsfile.commitlint` → Ensures commit messages follow **Conventional Commits** format.  

---

## Prerequisites  

1. **Trace Application** API Server: [GitHub Repo](https://github.com/cyse7125-sp25-team03/api-server)  
2. **Infrastructure Setup:** Uses [tf-gcp-infra](https://github.com/cyse7125-sp25-team03/tf-gcp-infra) to create clusters.  
3. **Database Migrations:** Managed by [db-trace-processor](https://github.com/cyse7125-sp25-team03/db-trace-processor).  
4. **Secrets Encryption:**
   - Create a **key-ring** and **key** on CMEK in GCP.  
   - The user should have **Service Account Admin** role.  
   - To decrypt secrets, the service account needs `roles/cloudkms.cryptoKeyEncrypterDecrypter`.  
5. **Ensure proper Kubernetes permissions** for deployments, secrets, and Helm operations.  

---

## References  

- **Helm:** [Helm Documentation](https://helm.sh/docs/)  
- **Helm-Secrets Plugin:** [GitHub](https://github.com/jkroepke/helm-secrets)  
- **SOPS:** [GitHub Releases](https://github.com/getsops/sops/releases)  
- **Kubernetes Secrets:** [K8s Docs](https://kubernetes.io/docs/concepts/configuration/secret/)  
- **Semantic-Release:** [Official Docs](https://semantic-release.gitbook.io/semantic-release/)  
- **Bitnami PostgreSQL Chart:** [Helm Chart](https://bitnami.com/stack/postgresql/helm)  
- **Conventional Commits:** [Commit Guidelines](https://www.conventionalcommits.org/en/v1.0.0/)  
