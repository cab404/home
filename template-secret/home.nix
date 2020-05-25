# This file is overlayed on top of the main config to personalize it.
{ ... }: {
  home.username = "john";

  programs.git = {
    userName = "John Smith";
    userEmail = "john@example.com";
    signing = {
      key = "1BB96810926F4E715DEF567E6BA7C26C3FDF7BB4";
      signByDefault = true;
    };
  };

  programs.ssh.matchBlocks = let
    is = (user: identityFile: { inherit user identityFile; });
  in
  {
    # You can list your ssh key to hostname associations here.
    "example.com" = is "john" "~/.ssh/id_rsa";
  };

}
