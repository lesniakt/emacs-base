# Use with home-manager.lib.homeManagerConfiguration and extraSpecialArgs.inputs.
{ inputs, pkgs, ... }: {
  imports = [ inputs.emacs-base.homeManagerModules.default ];
  targets.genericLinux.enable = true;
  programs.emacs-base.enable = true;
  programs.emacs.package = pkgs.emacs-nox;
  # Supply home.username/homeDirectory/stateVersion in your Home Manager configuration.
  # Start `emacs -nw` inside SSH. No GUI libraries or system service are required.
}
