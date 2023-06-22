source .env

echo -e ${DATA_E2E_LLM_REGISTRY_PASSWORD} | docker login -u ${DATA_E2E_LLM_REGISTRY_USERNAME} --password-stdin

docker build -t \
    --build-arg IMAGE_TAG_VAL=${DATA_E2E_POSTGRESML_IMAGE_TAG} \
    --build-arg PG_VS_VAL=${DATA_E2E_POSTGRESML_VERSION} \
    ${DATA_E2E_LLM_REGISTRY_USERNAME}/postgresml-bitnami:${DATA_E2E_POSTGRESML_IMAGE_TAG} .

docker push \
    ${DATA_E2E_LLM_REGISTRY_USERNAME}/postgresml-bitnami:${DATA_E2E_POSTGRESML_IMAGE_TAG}