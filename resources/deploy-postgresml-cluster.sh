source .env

# Create namespace
kubectl create ns ${DATA_E2E_POSTGRESML_NS}

# Deploy PVC
kubectl apply -f resources/db/postgresml-cluster-pvc.yaml \
      -n ${DATA_E2E_POSTGRESML_NS}

# Install Postgres instance
envsubst < resources/db/postgresml-cluster-values.yaml | helm install postgresml-bitnami \
      oci://registry-1.docker.io/bitnamicharts/postgresql \
      -n ${DATA_E2E_POSTGRESML_NS} \
      -f -