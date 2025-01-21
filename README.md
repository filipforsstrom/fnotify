# fnotify

A file watcher that sends desktop notifications.

## Nix

### Run on startup

Add this repoisitory as an input: `fnotify.url = "github:filipforsstrom/fnotify";`

Add it as a module: `inputs.fnotify.nixosModules.default`

Add a nix file for options:

```
{...}: {
  services.fnotify = {
    enable = true;
    dir = "/dev";
    prefix = "tty";
    event = "create";
    user = "your_user";
  };
}
```

### Building

Run `nix build`

### Development

Run `nix flake`
