LIBYANG_VERSION		?= c2b2f083a993873f5bd23383605ede3b60d60e58
SYSREPO_VERSION		?= ace418e827d4846d6cf62149d18c6080bb7e73bd
LIBNETCONF2_VERSION	?= 4d9d7993d710f1a9d17657e19a2d1eec803f3d6b
NETOPEER2_VERSION	?= d6dc2f49ce47ef3978e4df37e4266e760b0c54e8

.PHONY: all

all: build run

build: Dockerfile
	docker build \
		-t erap320/issue-2842 \
		-f Dockerfile . \
		--build-arg LIBYANG_VERSION=${LIBYANG_VERSION} \
		--build-arg SYSREPO_VERSION=${SYSREPO_VERSION} \
		--build-arg LIBNETCONF2_VERSION=${LIBNETCONF2_VERSION} \
		--build-arg NETOPEER2_VERSION=${NETOPEER2_VERSION}

run:
	docker run --rm -it erap320/issue-2842