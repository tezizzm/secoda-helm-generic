# secoda-helm-generic
**On prem Secoda Helm with all external dependencies**

This is a generic Helm chart for Secoda on-premises installation. It only installs the Secoda frontend and API services and does not provision an ingress or any of the external service dependencies.

## Service Prerequisites
The helm chart requires these services to run. All of the services must be accessible from the Kubernetes cluster nodes:

* Postgres Database with minimum resources of
  * Postgres 14.x
  * 2 CPU
  * 8G Memory
  * 100G Storage
  * An admin-level account named `keycloak` with password authentication
* Redis Cache
  * Redis 6.2.x
  * 1 CPU
  * 2G Memory
  * Cluster Mode Disabled **SECODA WILL NOT WORK WITH CLUStERED REDIS**
  * 1 or more replicas
* Elastic Search or Open Search
  * OpenSearch 2.x/ElsasticSearch 8.x
  * 1 CPU
  * 4G Memory
  * 20G Disk Storage
  * 1 or more cluster nodes
  * A master user account with user name/password authentication
  * If AWS OpenSearch, the Access Policy must be set to "Only use fine-grained access control" (Allow open access to the domain)

## Configuration and Secrets Setup
### Parameters in `values.yaml`

In `values.yaml` you will need to set `datastores.secoda.authorized_domains` to a comma-separated list of email domains that are allowed to log in to your on-premises Secoda. This is an important security feature that should not be skipped.

Also, resource allocations for the `api` and `frontend` containers are defined in the `values.yaml` file. You may need to increase these as your Secoda instance usage grows.

### Secrets in `secoda-secrets.sh` and `secoda-secrets.env`

All secrets must be populated before running `helm install`

`secoda-secrets.env` is where you set all of the connection values for your external Postgres, Redis and Open/Elastic Search services. There are basic examples included in the file for the more complex Redis and Postgres connection strings. The `secoda-secrets.env` file is loaded to its kubernetes secret by a `kubectl` command in `secoda-secrets.sh`

Before running `secoda-secrets.sh` you will need to set the `--docker-password` flag in the `kubectl create secret docker-registry secoda-dockerhub` command to the password provided by Secoda, and populate the `secoda-secrets.env` file with the connection settings for your external services. `secoda-secrets.sh` creates the `secoda` namespace and will create all of the secrets in this namespace.

If you need to reset any of the secret values, just run 
```
kubectl -n secoda delete secret <secret-name>
```
then rerun `secoda-secrets.sh` and optionally restart the secoda pods to pick up the new secrets

## Installing the Secoda Helm Chart

After editing the `values.yaml file and `running `secoda-secrets.sh` your Kubernetes cluster will be ready to install the Secoda Helm chart.

### Installing from source

From the base of the repository, run:
```
helm install -n secoda -f values.yaml secoda ./charts/secoda/
```

### Installing from the Secoda Repository

You still need to ensure all of the dependencies and secrets are set up along with any `values.yaml` settings. Then run
```
helm repo add secoda https://secoda.github.io/secoda-helm-generic
helm install -n secoda -f values.yaml secoda secoda/secoda
```


## Updating Secoda

* The Secoda Helm is configured to pull the latest images automatically on restart.
* `kubectl rollout restart deployment -n secoda` will redeploy the application with the latest images.

## Ingress Setup
An example ingress file, `ingress_example.yaml` is included. You will need to modify this to work with your preferred ingress class, which must also be installed to the kubernetes cluster. For most use cases, only the `spec.ingressClassName` and `spec.rules.0.host` should need to be modified. Then the ingress can be deployed with 
```
kubectl apply -f ingress_example.yaml
```
