# Contributing

Keep changes focused and describe the problem they solve. For larger changes,
open an issue first to discuss the approach.

## Development

- Keep the base configuration portable across Linux and macOS.
- Use Emacs Lisp for editor behavior and Nix for packaging and installation.
- Keep examples generic and use synthetic data in tests.
- Update documentation when changing setup or behavior.
- Add or update tests when fixing bugs or changing behavior.

## Testing

Run the checks before submitting a pull request:

```sh
nix flake check -L
```

For changes affecting remote editing, also run the loopback SSH tests:

```sh
nix shell nixpkgs#python3 nixpkgs#openssh --command python3 tests/ssh-fixture.py
```

In your pull request, describe the change, how you tested it, and any platform
limitations. Note any manual GUI testing separately from automated checks.

## License

Contributions are provided under the repository's [MIT license](LICENSE).
Only submit material you have the right to contribute under that license, and
preserve applicable copyright and license notices.
