start:
	open https://cloud.redhat.com/openshift/install/crc/installer-provisioned
	crc start
	eval $(crc oc-env)
	oc login -u developer -p developer https://api.crc.testing:6443

stop:
	crc stop

delete:
	crc delete

console:
	open https://console-openshift-console.apps-crc.testing 

new_project:
	oc new-project hello-project

app:
	#oc new-app http://localhost:5000/hello
	oc new-app hello
	oc expose svc/hello

delete_project:
	oc delete all --all

deploy:
	kubectl create deployment hello-node --image=localhost:5000/hello

registry:
	oc policy add-role-to-user registry-viewer "kube:admin"
	oc policy add-role-to-user registry-editor "kube:admin"
	#oc login -u kubeadmin -p $$(oc whoami -t)  default-route-openshift-image-registry.apps-crc.testing
	oc project openshift-image-registry

push:
	docker tag hello openshift-image-registry/hello-project/hello 
	docker push openshift-image-registry/hello-project/hello 
	#docker tag hello default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker push default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 

