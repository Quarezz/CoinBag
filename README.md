# CoinBag

CoinBag is a personal finance tracker. This repository contains two separate
implementations:

- `CoinBag/` – the original iOS code written in Swift.
- `coinbag_flutter/` – a Flutter rewrite that targets multiple platforms.

## Web version

A GitHub Actions workflow builds the Flutter project for the web and publishes
the result to GitHub Pages. Once Pages is enabled for the repository the latest
build will be available from the `gh-pages` branch.

Pull requests also trigger preview deployments under `gh-pages/pr-<number>` so
changes can be tested before merging.

### Local build

To build the web app locally you need the Flutter SDK installed.
Run the following commands from the project root:

```bash
cd coinbag_flutter
flutter pub get
flutter build web --release --base-href /CoinBag/
```

The compiled output will appear in `coinbag_flutter/build/web`.

When deploying to GitHub Pages, specify the `--base-href` option so that
asset paths are resolved relative to the repository name. If you deploy the
web app at a different root path, adjust the value accordingly.
