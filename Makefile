

.PHONY: build
build:
	sudo nixos-rebuild switch --flake . -L

.PHONY: deploy
deploy/%:
	$(MAKE) send-secrets/$*
	deploy -s .\#$* --ssh-user root

.PHONY: send-secrets
send-secrets/%:
	YOLO=YES scripts/send-secrets.sh $*
