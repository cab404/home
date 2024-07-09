#!/usr/bin/env nu

# First of all, building the packages

module log {

  def colorprint [
    tag: string
    text: string
    start: string
    end: string
    textparams: record
  ] {
    print -e (""
      + (ansi --escape {attr: b})
      + ($tag | ansi gradient --fgstart $start --fgend $end)
      + (": ")
      + (ansi reset)
      + (ansi --escape $textparams)
      + ($text)
      + (ansi reset)
    )
  }

  export def error [
    text: string
  ] {
    colorprint "toss/error" $text '0xff0000' '0xff2200' {fg: 'white', bg: 'red', attr: b}
  }

  export def info [
    text: string
  ] {
    colorprint "toss/info" $text '0xffff00' '0x00ff00' { attr: i }
  }

  export def debug [
    text: string
  ] {
    colorprint "toss/debug" $text '0xffff00' '0xff2200' { }
  }

}

use log

def eval [
  code: string
] nothing -> string {
  nix eval --json $".#($code)" | from json
}

def nixBuild [
  attr: string
  --flake_path: string = "."
  ...additional_params: string
] nothing -> string {
  nix build $"($flake_path)#($attr)" --no-link --print-out-paths ...$additional_params
}

def nixBuildCommand [
  attr: string
  --flake_path: string = "."
  ...additional_params: string
] nothing -> list<string> {
  [nix build $"($flake_path)#($attr)" --no-link --print-out-paths ...$additional_params]
}


def configAttr [machine: string] nothing -> string { $"nixosConfigurations.($machine).config.system.build.toplevel" }

# Get all host settings from flake
def allHostSettings [] nothing -> string {
  nix eval --quiet --quiet --json ".#nodeMeta" --apply "builtins.mapAttrs (k: v: v.settings)" | from json
}

# i guess with `yeet` out of question, `toss` is somewhat okay name for that tool
export def hosts [] nothing -> list<string> {
  allHostSettings | columns
}

export def "main local" [] {
  let hostSettings = allHostSettings;
  let hostname = (hostname)

  if ($hostname not-in $hostSettings) {
    log error "Can't build for local system, hostname not found in the settings"
    exit 1
  }

  log info $"Starting configuration build for ($hostname)"
  let configPath = buildConfig $hostname
  log info "Configuration built successfully"
  log debug $"Path: ($configPath)"

  log info "Activating..."
  run-external sudo $"($configPath)/bin/switch-to-configuration" switch

  log info "Done!"
}

export def "main send-secrets" [
  hostname: string@hosts
] {
  let hostSettings = allHostSettings;
  let hostInfo = $hostSettings | get ($hostname)
  rsync -avP $"secrets/($hostname)/." $"root@($hostInfo.host):/secrets"
}

export def "main build" [
  hostname: string@hosts # What host to
  --eval_host: string = "daemon" # Where to copy the closure for evaluation. Build host must be accessible from there.
  --build_host: string = "daemon" # Where to build the closure. Target host must be accessible from there.
  --target_host: string = "daemon" # Where to copy the final system.
] {
  let hostSettings = allHostSettings;

  if ($hostname not-in $hostSettings) {
    log error "Can't build for local system, hostname not found in the settings"
    exit 1
  }

  let hostInfo = $hostSettings | get ($hostname)

  # We won't be messing around with copying stuff ourselves.
  # nix archive → nix copy → nix build → nix copy
  # 1. Eval
  log info $"Sending source to build host ($build_host)"
  let archiveInfo = nix flake archive --json | from json
  nix copy --to $build_host $archiveInfo.path

  log info $"Evaluating system"
  let drvPath = (nix eval ($archiveInfo.path + "#" + (configAttr $hostname) + ".drvPath") --offline --json) | from json
  nix copy --to $build_host $drvPath

  log info $"Building system on ($build_host)"
  let buildCommand = [
    nix-build $drvPath
    --no-out-link
    --log-format bar-with-logs
  ]

  log debug $'Running ($buildCommand) on ($hostInfo.host)'
  let builtSystem = run-external ssh $"root@($hostInfo.host)" ...$buildCommand
  log debug $"Built: ($builtSystem)"
  # log info $"System built; sending to target host"
  # log debug $"Path: ($builtSystem)"
  # run-external ssh ...[root@($hostInfo.host) nix copy --to $target_host $builtSystem]

  log debug $"Activating via SSH on target host"
  ssh $"root@($hostInfo.host)" $"($builtSystem)/bin/switch-to-configuration" switch
  # now for connection part

}

export def "main" [] {
  log error "doin' it wrongly, run with --help"
  log info "you have some nodes 'ere"
  for node in (allHostSettings) {
    log info ($node | to json)
  }
}
