function usage() {
    
    echo
    echo "Usage:"
    echo " $0 [command] [options]"
    echo " $0 --help"
    echo
    echo "Example:"
    echo " $0 install"
    echo
    echo "COMMANDS:"
    echo "   install                  Set up the demo projects and deploy demo apps"
    echo "   uninstall                Clean up and remove demo projects and objects"

}

ARG_COMMAND=

while :; do 
    case $1 in 
        install)
            ARG_COMMAND=install
	    ;;
        uninstall)
            ARG_COMMAND=uninstall
	    ;;
        -h | --help)
            usage
            exit 0
            ;;
        -- ) 
            shift
            break
            ;;
        *) # Default case: If no more options then break out of the loop.
            break
    esac
    shift
done

# VARIÁVEIS
ARGOCD_NS=openshift-config # deletar

function install() {

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
oc adm policy add-role-to-user edit system:serviceaccount:oqss-cicd:pipeline -n oqss-cicd

# ATRIBUINDO A PERMISSÃO "IMAGE-PULLER" PARA A SERVICE ACCOUNT DO OPENSHIFT PIPELINES
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-dev:pipeline -n oqss-dev
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-hom:pipeline -n oqss-hom
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-prod:pipeline -n oqss-prod
oc policy add-role-to-user system:image-puller system:serviceaccount:oqss-cicd:pipeline -n oqss-cicd

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

argocd app create -f oqss-dev/application-dev.yaml
argocd app create -f oqss-hom/application-hom.yaml
argocd app create -f oqss-prod/application-prod.yaml

}

function uninstall() {

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

}

case "$ARG_COMMAND" in
    uninstall)
        echo "Uninstalling demo..."
        uninstall
        echo
        echo "Delete completed successfully!"
        ;;

    install)
        echo "Deploying demo..."
        install
        echo
        echo "Provisioning completed successfully!"
        ;;
        
    *)
        echo "Invalid command specified: '$ARG_COMMAND'"
        usage
        ;;
esac
