# emacs-base

A Home Manager Emacs configuration for graphical macOS, Linux, and SSH terminals.

Includes Evil keybindings, Ivy/Counsel completion, Org capture and agenda, Magit,
and programming tools. Nix installs the packages and generates the init files;
Emacs Lisp defines editor behavior.

## Use

Add a flake input to your configuration using GitHub SSH access:

```nix
inputs.emacs-base = {
  url = "git+ssh://git@github.com/lesniakt/emacs-base.git";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.follows = "home-manager";
};
```

Pass `inputs` through Home Manager's `extraSpecialArgs`, then import and enable
the module in your Home Manager configuration:

```nix
{ inputs, ... }: {
  imports = [ inputs.emacs-base.homeManagerModules.default ];
  programs.emacs-base = {
    enable = true;
    orgDirectory = "~/org";
    agendaFiles = [ "TaskInbox.org" ];
  };
}
```

Commit your lockfile to pin the configuration. The module manages
`~/.emacs.d/init.el` and `early-init.el`; back up an existing unmanaged init before
activation. The module uses your Home Manager package set; standalone builds
in this repository use pinned Nixpkgs unstable. Existing package.el caches are
left untouched and unused.

Use standard `programs.emacs.package`, `extraPackages`, and `overrides` for package
customization. macOS defaults to native Emacs; Linux defaults to `pkgs.emacs-nox`.
Choose `pkgs.emacs-pgtk` explicitly for Wayland. No daemon or OS service is needed.
Packages and fonts are supplied by Nix, with no package downloads at startup.
See [Mac](examples/mac.nix) and [standalone Linux](examples/linux.nix) examples.

For native macOS font registration, add this to your **nix-darwin system**
configuration (not inside the Home Manager module):

```nix
fonts.packages = with pkgs; [ fira-code cantarell-fonts emacs-all-the-icons-fonts ];
```

This uses nix-darwin's font installation into `/Library/Fonts/Nix Fonts`.
The editor uses available fallback fonts until registration is complete.

## Customize Emacs

Use `extraConfig` for Emacs Lisp evaluated after the base configuration:

```nix
programs.emacs-base.extraConfig = ''
  (setq emacs-base-font-height 140)
  (emacs-base-setup-frame)
'';
```

Keep credentials out of Nix strings: generated configuration is readable in the
Nix store. Set machine-specific paths and additional integrations in your
Home Manager configuration.

## License

MIT covers this repository's original code. Dependencies retain their own
licenses. See [provenance](PROVENANCE.md) and [contributing guide](CONTRIBUTING.md).
