{
  outputs = {self}: {
    nixosModules = {
        home-manager = import ./home-manager;
    };
  };
}
