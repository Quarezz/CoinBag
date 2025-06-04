# Agent Developer Guide

This document outlines how to get started contributing to CoinBag as an automated agent developer. It provides instructions on verifying the Flutter build using **fvm**, and explains how to stay aligned with the project's existing planning documents.

## 1. Verify Build with FVM

CoinBag relies on **fvm** to ensure all developers use the same Flutter SDK version. The configuration can be found in `coinbag_flutter/.fvm/fvm_config.json`.

To confirm that you can build the Flutter project:

1. Install the specified SDK if it is not already cached:
   ```bash
   cd coinbag_flutter
   fvm install
   ```
2. Fetch dependencies:
   ```bash
   fvm flutter pub get
   ```
3. Attempt a build (for example an Android APK or a web build):
   ```bash
   fvm flutter build apk    # or `fvm flutter build web --release`
   ```
   The build requires network access for downloading artifacts. If the environment blocks these downloads, record the failure and raise it in the development plan.

## 2. Track Progress with the Development Plan

All tasks and their status are tracked in [`docs/MVP_development_plan.md`](MVP_development_plan.md). When you complete a step or discover a new issue, update that document in a pull request. Use the existing checklist format and keep the structure intact.

## 3. Consult the Product Requirements Document

Before adding new logic or modifying existing features, review [`docs/PRODUCT_REQUIREMENTS_DOCUMENT.md`](PRODUCT_REQUIREMENTS_DOCUMENT.md). The PRD clarifies intended behavior and highlights open questions. Referencing it prevents mistakes such as implementing out‑of‑scope features or ignoring important edge cases.

## 4. Reporting Questions

If you encounter blocking issues or uncertainties:

1. Add a brief note under the appropriate section of the development plan.
2. Summarize unresolved points in your PR description so maintainers are aware.

Keeping these documents up to date ensures the agent's contributions remain consistent with the overall roadmap.
