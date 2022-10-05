# VARIÁVEIS
ARGOCD_NS=openshift-config # deletar

# CRIANDO NAMESPACES
oc new-project oqss-dev
oc new-project oqss-hom
oc new-project oqss-prod
oc new-project oqss-cicd # deletar

# APLICANDO LABEL PARA ADMINISTRAÇÃO DO ARGOCD
oc label namespace oqss-dev argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-hom argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-prod argocd.argoproj.io/managed-by=${ARGOCD_NS}
oc label namespace oqss-cicd argocd.argoproj.io/managed-by=${ARGOCD_NS}

# ATRIBUINDO A PERMISSÃO "EDIT" PARA A SERVICE ACCOUNT DO OPENSHIFT PIPELINES
# (PERGUNTAR PARA O MAIDA PORQUE ELE USOU A SA PIPELINE DO PROJETO CICD, PORQUE ELE NÃO ENCONTRA ESSA SA. SERÁ QUE É PORQUE O PASSO ACIMA NÃO RODOU?)
oc adm policy add-role-to-user edit system:serviceaccount:oqss-dev:pipeline -n oqss-dev
oc adm policy add-role-to-user edit system:serviceaccount:oqss-hom:pipeline -n oqss-hom
oc adm policy add-role-to-user edit system:serviceaccount:oqss-prod:pipeline -n oqss-prod
oc adm policy add-role-to-user edit system:serviceaccount:oqss-prod:pipeline -n oqss-cicd

# ATRIBUINDO A PERMISSÃO "IMAGE-PULLER" PARA A SERVICE ACCOUNT DO OPENSHIFT PIPELINES
# (PERGUNTAR PARA O MAIDA PORQUE ELE USOU A SA PIPELINE DO PROJETO CICD, PORQUE ELE NÃO ENCONTRA ESSA SA. SERÁ QUE É PORQUE O PASSO ACIMA NÃO RODOU?)
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-dev:pipeline -n oqss-dev
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-hom:pipeline -n oqss-hom
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-prod:pipeline -n oqss-prod
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-prod:pipeline -n oqss-cicd

# INSTACIANDO APPLICATIONS NO ARGOCD

# argocd repo add https://github.com/redhat-oraex/oqss-cnp-manifests --username davidsf026 --password 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
# argocd repo add https://github.com/redhat-oraex/oqss-cnp-provisioning --username davidsf026 --password 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

argocd app create -f oqss-cicd/gitea-bootstrap.yaml

sleep 10

SETUP_GITEA_JOB_NAME=$(oc get job --selector=target-to-script=setup-gitea --no-headers -o custom-columns=":metadata.name")
oc wait --for=condition=complete job/${SETUP_GITEA_JOB_NAME} --timeout=600s

argocd app create -f oqss-cicd/nexus.yaml
argocd app create -f oqss-cicd/sonarqube.yaml
argocd app create -f oqss-cicd/pipeline.yaml

argocd app patch gitea --patch '{"spec": { "source": { "repoURL": "http://gitea-oqss-cicd.apps.middleware.rhbr-lab.com/gitea-admin/oqss-cnp-manifests" } }}' --type merge