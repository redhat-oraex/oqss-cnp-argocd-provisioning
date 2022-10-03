argocd app delete gitea -y
argocd app delete nexus -y
argocd app delete pipeline -y
argocd app delete sonarqube -y

echo
read -p "Aperte enter quando as aplicações forem devidamente deletadas..."
echo

oc delete project oqss-dev
oc delete project oqss-hom
oc delete project oqss-prod
oc delete project oqss-testes