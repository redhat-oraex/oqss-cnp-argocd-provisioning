# VARIÁVEIS
ARGOCD_NS=openshift-config
CICD_NS=oqss-testes

# CRIANDO NAMESPACES
oc new-project oqss-dev
oc new-project oqss-hom
oc new-project oqss-prod
oc new-project ${CICD_NS} # deletar

# APLICANDO LABEL PARA ADMINISTRAÇÃO DO ARGOCD
oc label namespace oqss-dev argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-hom argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-prod argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace ${CICD_NS} argocd.argoproj.io/managed-by=${ARGOCD_NS}

# ATRIBUINDO A PERMISSÃO "EDIT" PARA A SERVICE ACCOUNT DO OPENSHIFT PIPELINES
# (PERGUNTAR PARA O MAIDA PORQUE ELE USOU A SA PIPELINE DO PROJETO CICD, PORQUE ELE NÃO ENCONTRA ESSA SA. SERÁ QUE É PORQUE O PASSO ACIMA NÃO RODOU?)
oc adm policy add-role-to-user edit system:serviceaccount:oqss-dev:pipeline -n oqss-dev
oc adm policy add-role-to-user edit system:serviceaccount:oqss-hom:pipeline -n oqss-hom
oc adm policy add-role-to-user edit system:serviceaccount:oqss-prod:pipeline -n oqss-prod
oc adm policy add-role-to-user edit system:serviceaccount:oqss-prod:pipeline -n ${CICD_NS}

# ATRIBUINDO A PERMISSÃO "IMAGE-PULLER" PARA A SERVICE ACCOUNT DO OPENSHIFT PIPELINES
# (PERGUNTAR PARA O MAIDA PORQUE ELE USOU A SA PIPELINE DO PROJETO CICD, PORQUE ELE NÃO ENCONTRA ESSA SA. SERÁ QUE É PORQUE O PASSO ACIMA NÃO RODOU?)
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-dev:pipeline -n oqss-dev
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-hom:pipeline -n oqss-hom
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-prod:pipeline -n oqss-prod
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-prod:pipeline -n ${CICD_NS}

# INSTACIANDO APPLICATIONS NO ARGOCD
argocd app create -f oqss-cicd/gitea.yaml
argocd app create -f oqss-cicd/nexus.yaml
argocd app create -f oqss-cicd/sonarqube.yaml
argocd app create -f oqss-cicd/pipeline.yaml