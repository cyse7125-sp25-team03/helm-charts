# Helm Chart for Trace API Server

This repository contains Helm charts for deploying an API server and a Bitnami PostgreSQL database on a Kubernetes cluster. 

## Repository Structure
```
./postgres/                  # Bitnami PostgreSQL Helm chart
./api-server/Chart.yaml       # Helm chart definition for API server
./api-server/values.yaml      # Configuration values for API server
./api-server/.sops.yaml       # SOPS configuration for secret encryption
./api-server/secrets.enc.yaml.enc  # Encrypted secrets file
./api-server/.helmignore      # Helm ignore file
./api-server/templates/       # Kubernetes resource templates
./.releaserc.json             # Configuration for semantic-release
./Jenkinsfile                 # CI/CD pipeline for semantic-release
./Jenkinsfile.prcheck         # Helm lint and template check pipeline
./Jenkinsfile.commitlint      # Commit message linting
package.json                  # Semantic-release dependencies
package-lock.json             # Dependency lock file
```

## Deployment Steps

### 1. Encrypt Secrets with SOPS
Create a `secrets.enc.yaml` file with the following structure:
```yaml
apiServer:
  postgres:
    username: "your_username" 
    password: "your_password" 
  serviceAccount:
    gsaEmail: "your_service_account_email"
```

Then encrypt the file:
```sh
sops --encrypt --input-type yaml --output-type yaml secrets.enc.yaml > secrets.enc.yaml.enc
```

### 2. Install Dependencies on Cluster
Install Helm and required plugins:
```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm plugin install https://github.com/jkroepke/helm-secrets
```

Install SOPS for secret management:
```sh
curl -LO https://github.com/getsops/sops/releases/download/v3.9.4/sops-v3.9.4.linux.amd64
sudo mv sops-v3.9.4.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops
```

### 3. Create Namespaces
```sh
kubectl create namespace postgres
kubectl create namespace api-server
```

### 4. Install PostgreSQL
```sh
cd helm-charts/
helm dependency build ./postgresql/
helm install pg ./postgresql/ -n postgres
```

### 5. Check PostgreSQL Status
```sh
kubectl get pods -n postgres --watch
```

### 6. Create DockerHub Secret for API Server
```sh
kubectl create secret docker-registry dockerhub-secret \
  --docker-username=your_username \
  --docker-password=your_pat \
  --docker-email=your_email -n api-server 
```

### 7. Deploy API Server with Encrypted Secrets
```sh
helm secrets install api-server ./api-server -n api-server \
  -f ./api-server/values.yaml \
  -f ./api-server/secrets.enc.yaml.enc
```

### 8. Monitor API Server Pods
```sh
kubectl get pods -n api-server --watch
```

### 9. Access API Server
Port-forward to test APIs:
```sh
kubectl port-forward -n api-server pod/POD_NAME 8080:8080 &
```
Or exec into the pod:
```sh
kubectl exec -n api-server -it POD_NAME -- sh
```

## Prerequisites & Additional Information

1. This API server is used for the **Trace Application**: [GitHub Repo](https://github.com/cyse7125-sp25-team03/api-server)
2. The **tf-gcp-infra** project provisions the cluster: [GitHub Repo](https://github.com/cyse7125-sp25-team03/tf-gcp-infra)
3. The **db-trace-processor** manages database migrations: [GitHub Repo](https://github.com/cyse7125-sp25-team03/db-trace-processor)
4. To encrypt secrets, you need a key-ring and key created on **CMEK in GCP** and require the **Service Account Admin** role.
5. To decrypt secrets for Helm, the service account must have the **roles/cloudkms.cryptoKeyEncrypterDecrypter** role.
6. Ensure you have the appropriate permissions to execute the commands above.

## References
- [Helm Installation Guide](https://helm.sh/docs/intro/install/)
- [Helm Secrets Plugin](https://github.com/jkroepke/helm-secrets)
- [SOPS Releases](https://github.com/getsops/sops/releases)
- [Kubernetes Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
- [Bitnami PostgreSQL Helm Chart](https://bitnami.com/stack/postgresql/helm)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Google Cloud Key Management Service (KMS)](https://cloud.google.com/kms/docs/)
- [Helm Secrets Usage](https://github.com/jkroepke/helm-secrets#usage)
- [Kubernetes Port Forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application/)
