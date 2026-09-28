#!/bin/sh

set -e

################################################################################
# repo
################################################################################
helm repo add stable https://charts.helm.sh/stable
helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo add fusionauth https://fusionauth.github.io/charts
helm repo update > /dev/null


################################################################################
# chart
################################################################################
STACK="fusionauth"
CHART="fusionauth/fusionauth"
CHART_VERSION="1.68.0"
NAMESPACE="fusionauth"

if [ -z "${MP_KUBERNETES}" ]; then
  # use local version of values.yml
  ROOT_DIR=$(git rev-parse --show-toplevel)
  VALUES="$ROOT_DIR/stacks/fusionauth/values.yml"
else
  # use github hosted master version of values.yml
  VALUES="https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/fusionauth/values.yml"
fi

kubectl annotate --namespace "$NAMESPACE" secret/fusionauth-credentials \
  helm.sh/resource-policy=keep --overwrite

helm upgrade "$STACK" "$CHART" \
--namespace "$NAMESPACE" \
--values "$VALUES" \
--set database.dbUser.existingSecret.name="fusionauth-credentials" \
--set database.dbUser.existingSecret.passwordKey="password" \
--set database.rootUser.existingSecret.name="fusionauth-credentials" \
--set database.rootUser.existingSecret.passwordKey="rootpassword" \
--version "$CHART_VERSION" \
--set search.host=opensearch-cluster-master
