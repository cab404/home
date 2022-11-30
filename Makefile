

.PHONY: build
build:
	sudo nixos-rebuild switch --flake . -L

.PHONY: deploy
deploy/%:
	$(MAKE) send-secrets/$*
	deploy -s .\#$* --ssh-user root -- -L

switch:
	nixos-rebuild switch --flake . --target-host root@localhost

.PHONY: send-secrets
send-secrets/%:
	YOLO=YES scripts/send-secrets.sh $*

home:
	deploy -s .\#local-home.cab-home --magic-rollback false --auto-rollback false
