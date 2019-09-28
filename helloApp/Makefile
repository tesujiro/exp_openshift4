MODULE=hello
TARGET_OS=linux
REPO="localhost:5000"

all:
	go build -o $(MODULE)
test:
	go test -v .
bench:
	go test -bench . -benchmem
cover:
	go test -v . -coverprofile=cover.out && go tool cover -html=cover.out -o cover.html

.PHONY: build_linux
build_linux:
	GOOS=$(TARGET_OS) go build -o $(MODULE).$(TARGET_OS)

.PHONY: container
container: container_build container_deploy

.PHONY: container_build
container_build:
	docker build -t $(MODULE) .

.PHONY: container_deploy
container_deploy:
	docker tag $(MODULE) $(REPO)/$(MODULE)
	docker push $(REPO)/$(MODULE)
	docker rmi $(REPO)/$(MODULE)
	docker pull $(REPO)/$(MODULE)

.PHONY: private_registry
private_registry:
	docker pull registry:2.3.0
	docker run -d -p 5000:5000 -v /var/opt:/var/lib/registry --restart=always --name private_registry registry:2.3.0

