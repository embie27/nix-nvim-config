return {
  settings = {
    nixd = {
      nixpkgs = {
        -- nixd requires some configuration in flake based configs.
        -- luckily, the nixCats plugin is here to pass whatever we need!
        -- we passed this in via the `extra` table in our packageDefinitions
        -- for additional configuration options, refer to:
        -- https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
        expr = [[import (builtins.getFlake "]] .. nixCats.extra("nixdExtras.nixpkgs") .. [[") { }   ]],
      },
      formatting = {
        command = { "nixfmt" }
      },
      diagnostic = {
        suppress = {
          "sema-escaping-with"
        }
      }
    }
  }

}
