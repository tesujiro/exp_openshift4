start:
	open https://cloud.redhat.com/openshift/install/crc/installer-provisioned
	crc start
	crc oc-env
	eval $(crc oc-env)
	oc login -u developer -p developer https://api.crc.testing:6443

stop:
	crc stop

delete:
	crc delete

console:
	open https://console-openshift-console.apps-crc.testing 

grant:
	oc adm policy add-scc-to-user anyuid -z default
	oc adm policy add-scc-to-user anyuid -z default --as=system:admin

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

registry_login:
	#oc login -u kubeadmin -p BMLkR-NjA28-v7exC-8bwAk https://api.crc.testing:6443
	#oc policy add-role-to-user registry-viewer developer
	#oc policy add-role-to-user registry-editor developer
	oc registry login
	#oc login -u developer -p developer https://default-route-openshift-image-registry.apps-crc.testing:6443
	#https://default-route-openshift-image-registry.apps-crc.testing:5000
	#oc project openshift-image-registry
	#docker login -u developer -p developer $(oc registry login)

push:
	docker tag hello 172.30.209.47:5000/hello-project/hello 
	docker push 172.30.209.47:5000/hello-project/hello 
	#docker tag hello default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker push default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker tag hello openshift-image-registry/hello-project/hello 
	#docker push openshift-image-registry/hello-project/hello 
	#docker tag hello default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 
	#docker push default-route-openshift-image-registry.apps-crc.testing/hello-project/hello 

