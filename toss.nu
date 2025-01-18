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

  export def warn [
    text: string
  ] {
    colorprint "toss/warn" $text '0xcc5500' '0xcc3322' { attr: i }
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

def --env preloadHosts [] {
  if not ("tossHosts" in $env) {
    $env.tossHosts = (allHostSettings)
  }
}

def --wrapped nixBuild [
  attr: string
  --flake_path: string = "."
  ...rest: string
] nothing -> string {
  nix build $"($flake_path)#($attr)" --no-link --print-out-paths ...$rest
}

def --wrapped nixBuildCommand [
  attr: string
  --flake_path: string = "."
  ...rest: string
] nothing -> list<string> {
  [nix build $"($flake_path)#($attr)" --no-link --print-out-paths ...$rest]
}

def configAttr [machine: string] nothing -> string { $"nixosConfigurations.($machine).config.system.build.toplevel" }

# Get all host settings from flake
def allHostSettings [] nothing -> any {
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

# Mainly used to set control socket for Nix

# Runs command on a host.
# You can change it for your purposes (e.g to `tailscale ssh` if you are using tailscale), or use another switch user
def remoteExecute [
  --timeout: int
  --reconnect
  hostInfo: any
  cmdWithArgs: list<string>
] {
  log debug $'Running ($cmdWithArgs) on ($hostInfo.host)'

  mkdir .toss
  let port = $hostInfo.port? | default 22
  let user = $hostInfo.user? | default "root"
  $in | run-external ssh ...[
    -p $port

    # It is quite nice to have your own hostkeys if you are using multiple tailnets
  ...(if $timeout != null {[-o ConnectTimeout=($timeout)]} else {[]})
    # If we don't need to reconnect, use socket for connection
    ...(if not $reconnect {[
      -o $"ControlPath=(pwd)/.toss/ssh-toss-($hostInfo.name)"
      -o ControlMaster=auto
      -o ControlPersist=2m
      ]} else {[
      -o ControlMaster=no
      ]})

    -o ServerAliveCountMax=10
    -o ServerAliveInterval=1
    -o Compression=yes
    -o $"UserKnownHostsFile=(pwd)/.toss/hostkeys"
    $"root@($hostInfo.host)"
    ...$cmdWithArgs
  ]
}

def getHostInfo [hostname] any -> any {
  preloadHosts
  {name: $hostname} | merge ($env.tossHosts
  | get $hostname
  | default root user
  )
}

export def "main get-secrets" [
  hostname: string@hosts
] {
  preloadHosts
  let hostSettings = allHostSettings;
  let hostInfo = $hostSettings | getHostInfo $hostname
  rsync -avP $"root@($hostInfo.host):/secrets/." $"secrets/($hostname)/."
}

export def "main send-secrets" [
  hostname: string@hosts
] {
  let hostSettings = allHostSettings;
  let hostInfo = $hostSettings | getHostInfo $hostname
  rsync -avP $"secrets/($hostname)/." $"root@($hostInfo.host):/secrets/."
}

export def "main establish-socket" [
  hostname: string@hosts
] {
  preloadHosts

  let hostSettings = $env.tossHosts;
  let hostInfo = getHostInfo $hostname

  (
    ssh $"($hostInfo.user)@($hostInfo.host)"
      -L ./nix-socket-tiferet:/nix/var/nix/daemon-socket/socket
      nix-daemon

  )
}

export def "main build" [
  hostname: string@hosts
  # --eval_host: string = "daemon" # Where to copy the closure for evaluation. Build host must be accessible from there.

  # Where to build the closure. Target host must be accessible from there.
  --build_host: string
  # Where to copy the final system.
  --target_host: string
  # Whether to check the connectivity to the host after switching configurations. Helps with locking yourself out.
  --rollback-if-stuck
] {
  preloadHosts

  let hostSettings = $env.tossHosts;
  let hostInfo = getHostInfo $hostname

  # We can technically have implcit parameters...
  # set-env hostInfo $hostInfo

  # TODO: Add user selection for profile switching
  # TODO: Add custom profile switching
  let eBuildHost = $build_host | default $"ssh-ng://root@($hostInfo.host)"
  let eTargetHost = $target_host | default $"ssh-ng://root@($hostInfo.host)"

  log debug $"Build host: ($eBuildHost)"
  log debug $"Target host: ($eTargetHost)"

  if ($hostname not-in $hostSettings) {
    log error "Can't build for local system, hostname not found in the settings"
    exit 1
  }

  # We won't be messing around with copying stuff ourselves.
  # nix archive → nix copy → nix build → nix copy
  # 1. Eval
  # log info $"Sending source to build host ($eBuildHost)"
  # let archiveInfo = nix flake archive --json | from json
  # nix copy --to $eBuildHost $archiveInfo.path

  let drvPath = try {
    log info $"Evaluating system"
    ^nix eval (".#" + (configAttr $hostname) + ".drvPath") --json | from json
  } catch {
    log error $"Eval failed: exited with ($env.LAST_EXIT_CODE)"
    exit $env.LAST_EXIT_CODE
  }
  if (($drvPath | length) == 0) {
    log error "Eval produced no output path!"
    exit 1
  }
  log info $"Done eval: ($drvPath) ($drvPath | length)"

  try {
    log info $"Sending derivation to destination system. Expect ridiculously huge sizes."
    ^nix copy --log-format internal-json --derivation --to $eBuildHost $drvPath o+e>| nom --json
  } catch {
    log error $"Couldn't send derivation: exited with ($env.LAST_EXIT_CODE)"
    exit $env.LAST_EXIT_CODE
  }


  let buildCommand = [
    nix build $"'($drvPath)^*'"
    --print-out-paths
    # --log-format internal-json
  ]

  let builtSystem = try {
    log info $"Building system on ($eBuildHost)"
    (remoteExecute $hostInfo $buildCommand) # o+e>| nom --json
  } catch {
    log error $"Build failed: exited with ($env.LAST_EXIT_CODE | into string)"
    exit $env.LAST_EXIT_CODE
  }

  if ($builtSystem == "") {
    log error $"Built produced no output path!"
    exit 1
  }
  log debug $"Built: ($builtSystem)"

  if ($eTargetHost != $eBuildHost) {
    log info $"System built; sending to target host"
    log debug $"Path: ($builtSystem)"
    remoteExecute $hostInfo [ nix copy --to $eTargetHost $builtSystem ]
  }


  let time = 60;
  log info $"Priming un-stucking stepbrotherscript, ($time) second timer should be enough..."

  # Escapes string into something SH understands.
  # We need several layers of escaping, so mistakes will be made if done by hand.
  # We also can emulate this behavior in code, but
  def shescape [] string -> string { ^sh ...[ -c 'read -sr A; printf %q "$A"' ] }

  let unstuckScript = "/nix/var/nix/profiles/system/bin/switch-to-configuration switch";
  let unstuckScriptStrapped = ([
    # Sleep, and then launch the script
    /bin/sh -c ($"sleep ($time);($unstuckScript)" | shescape)

    # Redirect to /dev/null, unhook from SSH session and print its PID for us to remember.
    ">/dev/null 2>&1 & { disown -ha; echo $!; }"
  ] | str join " ")

  let unstuckPid = $unstuckScriptStrapped | remoteExecute $hostInfo [ /bin/sh ] | into int
  log info $"Unstucksbrotherscript: ($unstuckScriptStrapped)"
  log info $"Un-stuck stepbrotherscript primed at PID ($unstuckPid)"


  log info $"Activating via SSH on target host"
  try {
    remoteExecute $hostInfo [ $"($builtSystem)/bin/switch-to-configuration" switch ]
  } catch {
    log error $"Exited with ($env.LAST_EXIT_CODE)"
    log error "sus"
  }

  try {
    log info $"Trying to deactivate un-stucking brotherscript..."
    remoteExecute --reconnect $hostInfo [ kill ($unstuckPid | into string) ]
  } catch {
    log error $"Failed to disarm, brother will help us get unstuck in several seconds."
  }

  log info $"Activation successful, updating system profile"
  remoteExecute $hostInfo [ nix-env -p /nix/var/nix/profiles/system --set $builtSystem ]
}

export def "main" [] {
  log warn "Run with --help if you need it"
  log info "List of available nodes"

  preloadHosts

  print (hosts | each { |name| getHostInfo $name})

}
