RUBY_IMAGE:=$(shell head -n 1 Dockerfile | cut -d ' ' -f 2)
IMAGE:=cd-example/hello_world
DOCKER:=tmp/docker

.PHONY: check
check:
	docker --version > /dev/null
	ansible --version > /dev/null

Gemfile.lock: Gemfile
	docker run --rm -v $(CURDIR):/data -w /data $(RUBY_IMAGE) \
		bundle package --all

$(DOCKER): Gemfile.lock
	docker build -t $(IMAGE) .
	mkdir -p $(@D)
	touch $@

.PHONY: build
build: $(DOCKER)

.PHONY: test-cloudformation
test-cloudformation:
	aws --region us-east-1 cloudformation \
		validate-template --template-body file://cloudformation/prereqs.json
	aws --region us-east-1 cloudformation \
		validate-template --template-body file://cloudformation/app.json

.PHONY: test-image
test-image: $(DOCKER)
	docker run --rm $(IMAGE) \
		ruby $(addprefix -r./,$(wildcard test/*_test.rb)) -e 'exit'

.PHONY: test-ci
test-ci: test-image

.PHONY: push
push:
	docker tag $(IMAGE) $(UPSTREAM)
	docker push $(UPSTREAM)

.PHONY: clean
clean:
	rm -rf $(DOCKER)
