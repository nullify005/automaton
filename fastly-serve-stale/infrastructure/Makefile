STACK_NAME:="infrastructure-fastly-serve-stale-test-v1"
KUBE_NAME:="fastly-serve-stale"

setup:
		bash -c ". ~/.rvm/scripts/rvm; \
			rvm use `cat .ruby-version`; \
			bundle install --path vendor/bundle"

sfn-create:
		bash -c ". ~/.rvm/scripts/rvm; \
			rvm use `cat .ruby-version`; \
			bundle exec sfn create $(STACK_NAME)"

sfn-print:
		bash -c ". ~/.rvm/scripts/rvm; \
			rvm use `cat .ruby-version`; \
			bundle exec sfn print"

sfn-update:
		bash -c ". ~/.rvm/scripts/rvm; \
			rvm use `cat .ruby-version`; \
			bundle exec sfn update $(STACK_NAME) --file sparkleformation/stack.rb \
				-y --defaults --no-interactive-parameters"

helm-install:
		helm install ffxblue/blue-app --name $(KUBE_NAME) \
			--namespace $(KUBE_NAME) --values helm/values.yaml

helm-upgrade:
		helm upgrade $(KUBE_NAME) ffxblue/blue-app -f helm/values.yaml

logtail:
		stern -n $(KUBE_NAME) -t -s 5s fastly

fastly-plan:
		bash -c "cd cdn; \
			terraform plan -var \"version_comment=initial commit\" \
				-var-file vars/playpen.tfvars"

fastly-apply:
		bash -c "cd cdn; \
			terraform apply -var \"version_comment=initial commit\" \
				-var-file vars/playpen.tfvars"

scale-in:
		kubectl -n fastly-serve-stale scale deploy fastly-serve-stale-blue-app-app --replicas=0

scale-out:
		kubectl -n fastly-serve-stale scale deploy fastly-serve-stale-blue-app-app --replicas=3
