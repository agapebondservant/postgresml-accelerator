# PostgresML Accelerator

This is an accelerator that can be used to generate a Kubernetes deployment for [PostgresML](https://postgresml.org/).

* Install App Accelerator: (see https://docs.vmware.com/en/Tanzu-Application-Platform/1.0/tap/GUID-cert-mgr-contour-fcd-install-cert-mgr.html)
```
tanzu package available list accelerator.apps.tanzu.vmware.com --namespace tap-install
tanzu package install accelerator -p accelerator.apps.tanzu.vmware.com -v 1.0.1 -n tap-install -f resources/app-accelerator-values.yaml
Verify that package is running: tanzu package installed get accelerator -n tap-install
Get the IP address for the App Accelerator API: kubectl get service -n accelerator-system
```

Publish Accelerators:
```
tanzu plugin install --local <path-to-tanzu-cli> all
tanzu acc create postgresml --git-repository https://github.com/agapebondservant/postgresml-accelerator.git --git-branch main
```

## Contents
1. [Overview](#overview)
2. [Deploy Bitnami Postgres on Kubernetes<a name](#pgbitnami)

### Overview<a name="overview"/>
User-Defined Functions
- **run_llm_inference_task**: Invokes a HuggingFace pipeline using _postgresml_
  - Parameters:
  - _question_: Input prompt
  - _task_: HuggingFace task (summarization, question-answering, feature-extraction etc)
  - _task_model_: Large Language Model from public or private HuggingFace repository
  - _use_topk_: Flag indicating whether to use only the top k embedding chunks for the query
  - Returns: (Table object)
  - _Matched document link_
  - _Query result_ 
- **generate_batch_embeddings**: Generates and stores embeddings from a preconfigured datasource using _pgvector_
  - Parameters:
  - _N/A_
  - Returns:
  - _N/A_


### Deploy Bitnami Postgres on Kubernetes<a name="pgbitnami"/>
#### Prequisites:
-[ ] Install helm

1. Build the postgresml-enabled Postgres instance image
   (NOTE: Skip if already built;
   also, must build on a network with sufficient bandwidth - example, might run into issues behind some VPNs):
```
source .env
cd resources
build-postgresml-baseimage.sh
watch kubectl get pvc -n ${DATA_E2E_POSTGRESML_NS}
cd -
```

2. Deploy Postgres instance:
```
resources/deploy-postgresml-cluster.sh
watch kubectl get all -n ${DATA_E2E_POSTGRESML_NS}
```

3. To get the connect string for the postgresml-enabled instance:
```
export POSTGRESML_PW=${DATA_E2E_BITNAMI_AUTH_PASSWORD}
export POSTGRESML_ENDPOINT=$(kubectl get svc ${DATA_E2E_BITNAMI_AUTH_DATABASE}-bitnami-postgresql -n${DATA_E2E_POSTGRESML_NS} -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
echo postgresql://postgres:${POSTGRESML_PW}@${POSTGRESML_ENDPOINT}/${DATA_E2E_BITNAMI_AUTH_DATABASE}?sslmode=require
```

4. To delete the Postgres instance:
```
resources/delete-postgresml-cluster.sh
```