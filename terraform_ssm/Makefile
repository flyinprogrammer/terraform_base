apply:
	terraform apply tfplan
clean:
	rm -rf .terraform .terraform.lock.hcl tfplan
destroy:
	terraform destroy
fmt:
	terraform fmt -recursive .
get:
	terraform get -update
init:
	terraform init
plan:
	terraform plan -out tfplan
upgrade:
	terraform init -upgrade=true
