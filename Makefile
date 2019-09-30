start:
	crc start
	eval $(crc oc-env)
	oc login -u developer -p developer https://api.crc.testing:6443

stop:
	crc stop

delete:
	crc delete

console:
	open https://console-openshift-console.apps-crc.testing 

project:
	oc new-project hello-project

app:
	#oc new-app http://localhost:5000/hello
	oc new-app hello
	oc expose svc/hello

delete:
	oc delete all --all

deploy:
	kubectl create deployment hello-node --image=localhost:5000/hello


