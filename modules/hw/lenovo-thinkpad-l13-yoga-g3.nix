{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    # == NBFC
    # nbfc.nix
    ({ config, pkgs, lib, ... }:

      let
        modelName = "ThinkPad L13 Yoga (custom)";

        curve = [
          { DownThreshold = 0; UpThreshold = 0; FanSpeed = 0.0; }
          { DownThreshold = 43; UpThreshold = 50; FanSpeed = 10.0; }
          { DownThreshold = 52; UpThreshold = 60; FanSpeed = 35.0; }
          { DownThreshold = 62; UpThreshold = 70; FanSpeed = 65.0; }
          { DownThreshold = 71; UpThreshold = 80; FanSpeed = 85.0; }
          { DownThreshold = 78; UpThreshold = 87; FanSpeed = 100.0; }
        ];

        fanConfig = pkgs.writeText "l13-yoga-fan.json" (builtins.toJSON {
          NotebookModel = modelName;
          Author = "local";

          # Matches the shipped 20R4 config; changes how nbfc selects between
          # thresholds. Leave it alone unless the fan behaves oddly at boundaries.
          LegacyTemperatureThresholdsBehaviour = true;

          EcPollInterval = 2000;
          ReadWriteWords = false;

          # Hard safety net: above this, nbfc forces maximum regardless of curve.
          CriticalTemperature = 88;

          FanConfigurations = [{
            FanDisplayName = "Fan";

            ReadRegister = 149; # 0x95 tach
            WriteRegister = 148; # 0x94 FSW1

            # INVERTED: Min > Max is how nbfc expresses this.
            MinSpeedValue = 255; # stopped
            MaxSpeedValue = 0; # full speed

            IndependentReadMinMaxValues = false;
            MinSpeedValueRead = 0;
            MaxSpeedValueRead = 0;

            ResetRequired = true;
            # Raw register value on reset. 0 = FULL SPEED, deliberately: if a
            # reset ever races the handback to the EC, fail loud, not silent.
            FanSpeedResetValue = 0;

            TemperatureThresholds = curve;
          }];

          # Take host control: FCR1 = 0x14 (bit 4 host control | bit 2 enabled),
          # mirroring the DSDT's `FCR1 |= 0x10`. Reset to 0x04 clears bit 4.
          RegisterWriteConfigurations = [{
            WriteMode = "Set";
            WriteOccasion = "OnInitialization";
            Register = 147; # 0x93 FCR1
            Value = 20; # 0x14
            ResetRequired = true;
            ResetValue = 4; # 0x04
            ResetWriteMode = "Set";
            Description = "Set EC to manual control";
          }];
        });

        serviceConfig = pkgs.writeText "nbfc-service.json" (builtins.toJSON {
          SelectedConfigId = fanConfig;
          EmbeddedControllerType = "ec_sys";
        });

      in
      {
        environment.systemPackages = [ pkgs.nbfc-linux ];

        boot.kernelModules = [ "ec_sys" ];
        boot.extraModprobeConfig = ''
          options ec_sys write_support=1
        '';

        systemd.tmpfiles.rules = [
          "C /etc/nbfc/nbfc.json 0644 root root - ${serviceConfig}"
        ];

        systemd.services.nbfc = {
          description = "NoteBook FanControl";
          wantedBy = [ "multi-user.target" ];
          after = [ "multi-user.target" ];
          path = [ pkgs.kmod ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file ${serviceConfig}";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        # The EC reasserts fan control across suspend; re-apply on resume.
        powerManagement.resumeCommands = ''
          ${pkgs.systemd}/bin/systemctl restart nbfc.service
        '';
      }
    )
    #==
    inputs.nixos-hw.nixosModules.lenovo-thinkpad-l13-yoga
  ];

  # Disable the fucking clitoris
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Disable TrackPoint motion]
    MatchUdevType=pointingstick
    AttrEventCode=-REL_X;-REL_Y
  '';

  hardware.sensor.iio.enable = true;
  services.fprintd = on;
  services.acpid.enable = true;

  boot.extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  boot.kernelModules = [ "acpi_call" ];

  boot.kernelParams = [
    "quiet"
    "splash"
    "mitigations=off"

    "iwlwifi.amsdu_size=3"

    # --- i915 power saving (Tiger Lake / i5-1145G7) ---
    "i915.enable_fbc=1"            # framebuffer compression – saves memory bandwidth
    "i915.enable_psr=2"            # panel self-refresh level 2 (PSR2) – big display power win
    "i915.enable_psr2_sel_fetch=1" # selective fetch for PSR2 – reduces redrawn area
    "i915.enable_dc=4"             # deepest display C-state (DC5/DC6)
    "i915.fastboot=1"              # skip unnecessary mode-sets on boot
    "i915.enable_guc=3"            # GuC submission (1) + HuC auth (2) – offloads scheduling & enables power features
    "i915.disable_power_well=0"    # let the driver aggressively gate unused power wells
    "i915.enable_dpcd_backlight=1" # DPCD backlight control – more efficient on eDP panels

    "vm.swappiness=5"

  ];

}
