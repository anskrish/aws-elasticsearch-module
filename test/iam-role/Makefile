TERRAFORM=terraform
USER=$(shell id -un)

all:
	$(TERRAFORM) apply
	
clean:
	$(TERRAFORM) init
	$(TERRAFORM) destroy
	rm -fr .terraform terraform.tfstate terraform.tfstate.backup

