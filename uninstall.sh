argocd app delete gitea -y
argocd app delete nexus -y
argocd app delete pipeline -y
argocd app delete sonarqube -y
argocd app delete application-dev -y
argocd app delete application-hom -y
argocd app delete application-prod -y

echo
read -p "Pressione enter quando as aplicações forem devidamente deletadas..."
echo

oc delete project oqss-dev
oc delete project oqss-hom
oc delete project oqss-prod
oc delete project oqss-cicd