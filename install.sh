# VARIÁVEIS
ARGOCD_NS=openshift-config # deletar

# CRIANDO NAMESPACES
oc new-project oqss-dev
oc new-project oqss-hom
oc new-project oqss-prod
oc new-project oqss-cicd # deletar

# APLICANDO LABEL PARA ADMINISTRAÇÃO DO ARGOCD NOS NAMESPACES INSTANCIADOS ACIMA
oc label namespace oqss-dev argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-hom argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-prod argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-cicd argocd.argoproj.io/managed-by=${ARGOCD_NS}

# ATRIBUINDO A PERMISSÃO "EDIT" PARA A SERVICE ACCOUNT DO OPENSHIFT PIPELINES
oc adm policy add-role-to-user edit system:serviceaccount:oqss-dev:pipeline -n oqss-dev
oc adm policy add-role-to-user edit system:serviceaccount:oqss-hom:pipeline -n oqss-hom
oc adm policy add-role-to-user edit system:serviceaccount:oqss-prod:pipeline -n oqss-prod
oc adm policy add-role-to-user edit system:serviceaccount:oqss-prod:pipeline -n oqss-cicd

# ATRIBUINDO A PERMISSÃO "IMAGE-PULLER" PARA A SERVICE ACCOUNT DO OPENSHIFT PIPELINES
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-dev:pipeline -n oqss-dev
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-hom:pipeline -n oqss-hom
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-prod:pipeline -n oqss-prod
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-prod:pipeline -n oqss-cicd

# INSTACIANDO APPLICATIONS NO ARGOCD

# argocd repo add https://github.com/redhat-oraex/oqss-cnp-gitops --username davidsf026 --password ************************
# argocd repo add https://github.com/redhat-oraex/oqss-cnp-argocd-provisioning --username davidsf026 --password ************************

argocd app create -f oqss-cicd/gitea.yaml # APENAS PARA DEMONSTRAÇÃO, EM CLIENTES ELES CERTAMENTE JÁ TERÃO UM SERVIDOR GIT

sleep 10

SETUP_GITEA_JOB_NAME=$(oc get job --selector=target-to-script=setup-gitea --no-headers -o custom-columns=":metadata.name")
oc wait --for=condition=complete job/${SETUP_GITEA_JOB_NAME} --timeout=600s

argocd app create -f oqss-cicd/nexus.yaml
argocd app create -f oqss-cicd/sonarqube.yaml
argocd app create -f oqss-cicd/pipeline.yaml