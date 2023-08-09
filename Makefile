
.PHONY: hostname/%
hostname/%:
	echo `./scripts/hostname.sh $*`

toplevel = ".\#nixosConfigurations.$*.config.system.build.toplevel"
host = $(shell ./scripts/hostname.sh $(*))
remote_store = ssh-ng://root@$(host)

.PHONY: remote-build/%
remote-build/%:
	nix copy --derivation $(toplevel) -Lv --to $(remote_store) --option substitute true --offline --eval-cache
	nix build $(toplevel) -Lv --store $(remote_store) --print-out-paths --offline > .system-link-$*

.PHONY: remote-switch/%
remote-switch/%: 
	$(MAKE) remote-build/$* 
	$(MAKE) send-secrets/$*
	ssh root@$(host) nix build --profile /nix/var/nix/profiles/system `cat .system-link-$(*)`
	$(warn Switching over to `cat.system-link-$(*)`)
	ssh root@$(host) /nix/var/nix/profiles/system/bin/switch-to-configuration switch
	# nixos-rebuild switch -v --flake .'#'$* --use-substitutes --target-host root@`./scripts/hostname.sh $*`
	
.PHONY: switch/%

switch/%:
	nixos-rebuild switch -v --flake .'#'$* --use-substitutes --target-host root@`./scripts/hostname.sh $*`

.PHONY: switch
switch:
	nixos-rebuild switch -v --flake . --target-host root@localhost

.PHONY: send-secrets/%
send-secrets/%:
	YOLO=YES scripts/send-secrets.sh $*

