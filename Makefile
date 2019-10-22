start:
	open https://cloud.redhat.com/openshift/install/crc/installer-provisioned
	crc start
	crc oc-env
	eval $(crc oc-env)

login_developer:
	oc login -u developer -p developer https://api.crc.testing:6443

login_kubeadmin:
	oc login -u kubeadmin -p BMLkR-NjA28-v7exC-8bwAk https://api.crc.testing:6443

stop:
	crc stop

delete:
	crc delete

console:
	open https://console-openshift-console.apps-crc.testing 

grant:
	oc adm policy add-scc-to-user anyuid -z default
	oc adm policy add-scc-to-user anyuid -z default --as=system:admin
	# https://access.redhat.com/documentation/ja-jp/openshift_container_platform/4.1/pdf/registry/OpenShift_Container_Platform-4.1-Registry-ja-JP.pdf
	oc policy add-role-to-user registry-viewer developer
	oc policy add-role-to-user registry-editor developer

project:
	oc new-project hello-project

deploy_dertificate:
	#docker login -u kubeadmin -p $$(oc whoami -t)  default-route-openshift-image-registry.apps-crc.testing
	# https://access.redhat.com/solutions/4308191
	# ingress-operator
	#oc extract secret/router-ca --keys=tls.crt -n openshift-ingress-operator
	#mv tls.crt openshift_tls.crt
	#sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain openshift_tls.crt
	# https://access.redhat.com/solutions/3654811
	# image-registry.openshift-image-registry.svc
	oc extract secrets/image-registry-tls --keys=tls.crt -n openshift-image-registry
	mv tls.crt openshift_tls.crt
	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain openshift_tls.crt

publish_registry:
	# https://access.redhat.com/documentation/ja-jp/openshift_container_platform/4.1/pdf/registry/OpenShift_Container_Platform-4.1-Registry-ja-JP.pdf
	oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec": {"defaultRoute":true}}' --type=merge

registry_login:
	#oc login -u kubeadmin -p BMLkR-NjA28-v7exC-8bwAk https://api.crc.testing:6443
	#oc policy add-role-to-user registry-viewer developer
	#oc policy add-role-to-user registry-editor developer
	#oc registry login
	#oc login -u developer -p developer https://default-route-openshift-image-registry.apps-crc.testing:6443
	#https://default-route-openshift-image-registry.apps-crc.testing:5000
	#oc project openshift-image-registry
	#docker login -u developer -p developer $(oc registry login) default-route-openshift-image-registry.apps-crc.testing:5000
	#docker login -u developer -p developer default-route-openshift-image-registry.apps-crc.testing
	#docker login -u developer -p $$(oc whoami -t)  default-route-openshift-image-registry.apps-crc.testing
	#docker login -u kubeadmin -p $$(oc whoami -t)  default-route-openshift-image-registry.apps-crc.testing
	docker login -u tesujiro -p $$(oc whoami -t)  default-route-openshift-image-registry.apps-crc.testing

app: registry_login
	#oc new-app http://localhost:5000/hello
	oc project hello-project
	#oc project hello-project --insecure-skip-tls-verify=true
	#oc new-app hello
	#oc new-app hello --insecure-skip-tls-verify=true 
	#oc new-app --docker-image=hello
	#oc new-app --docker-image=default-route-openshift-image-registry.apps-crc.testing/hello-project/hello -l name=hello
	oc new-app --docker-image=default-route-openshift-image-registry.apps-crc.testing/hello-project/hello -l name=hello --insecure-registry=true --source-secret=regcred
	oc expose svc/hello

show_openshift_registry:
	oc project openshift-image-registry
	oc get svc
	oc get route

delete_project:
	oc project hello-project
	oc delete all --all
	oc delete project hello-project

deploy:
	#kubectl create deployment hello-node --image=localhost:5000/hello
	kubectl create deployment hello-node --image=default-route-openshift-image-registry.apps-crc.testing/hello-project/hello

secret:
	oc project hello-project
	#oc secret new-dockercfg regcred --docker-email="tesujiro@gmail.com" --docker-username="tesujiro" --docker-password="" --docker-server="localhost"
	oc create secret generic regcred --from-file=.dockerconfigjson=/Users/tesujiro/.docker/config.json --type=kubernetes.io/dockerconfigjson
	#oc secrets link builder secret/regcred --for=pull
	oc secrets link builder secret/regcred

push: registry_login
	docker tag hello default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	docker push default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker tag hello 172.30.209.47:5000/hello-project/hello 
	#docker push 172.30.209.47:5000/hello-project/hello 
	#docker tag hello default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker push default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker tag hello openshift-image-registry/hello-project/hello 
	#docker push openshift-image-registry/hello-project/hello 
	#docker tag hello default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker push default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 

### TODO: DELETE
SSL_KEY=ssl/server.key
SSL_CSR=ssl/server.csr
SSL_CRT=ssl/server.crt
.PHONY: ssl_certificate
ssl_certificate:
	-mkdir ssl
	openssl genrsa 2048 > $(SSL_KEY)
	openssl req -new -key $(SSL_KEY) > $(SSL_CSR)
	openssl x509 -days 3650 -req -signkey $(SSL_KEY) < $(SSL_CSR) > $(SSL_CRT)

### TODO: DELETE
create_certificate:
	#oc adm ca create-server-cert 
	oc adm ca create-api-client-config \
	    --signer-cert=$(SSL_CRT) \
	    --signer-key=$(SSL_KEY) \
	    --signer-serial=$(SSL_CSR) \
	    --hostnames='localhost' \
	    --certificate-authority=./registry.crt \
	    --client-dir=./client \
	    --user='' 
