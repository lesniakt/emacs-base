# Import this inside home-manager.users.<your-user> in nix-darwin.
# Pass inputs through home-manager.extraSpecialArgs in your flake.
{ inputs, ... }: {
  imports = [ inputs.emacs-base.homeManagerModules.default ];
  programs.emacs-base = {
    enable = true;
    # Define "remote" in your SSH configuration. Opening Org files requires
    # connectivity; use "~/org" for local files instead.
    orgDirectory = "/ssh:remote:~/org";
  };
  # SSH aliases, home.username, home.homeDirectory, and home.stateVersion belong
  # to the consuming configuration. No remote host is contacted during activation.
}
