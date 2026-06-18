# Changelog

## 0.80

This is the first experience-polish update after the v0.79 public release.

### Highlights

- Refined the liquid glass and fallback frosted-glass visual system, including shape refraction, Optical Border, capture clarity, button translucency, and reduced over-bright rim highlights.
- Upgraded the bottom Dock interaction with nonlinear press/drag magnification, smoother icon return motion, and animated liquid-glass lens participation.
- Restored Android predictive back behavior through Flutter's `PredictiveBackPageTransitionsBuilder` and reduced heavy transition effects on secondary pages.
- Improved onboarding so the tutorial starts only after user confirmation, records completion only after the final step, and behaves better on small screens.
- Added the `值谱｜轻量卡片` 2x1 Android widget and refreshed widget layouts, previews, size constraints, quick action cards, and HyperOS / MIUI compact variants.
- Polished sticker mode with a consistent light-mode paper-card style, subtle rotation, improved shadowing, and dark-mode cards that follow the app surface.
- Reduced release size by focusing release packaging on `arm64-v8a`, keeping only Chinese and English resources, and retaining minification and resource shrinking.

### Third-Party Notices

- Added `THIRD_PARTY_NOTICES.md` and README acknowledgement for `liquid_glass_easy` 2.0.1.
- Release notes should continue to disclose that Valora uses `liquid_glass_easy` for real-time liquid glass, refraction, blur, Optical Border, and dynamic lens rendering.

## 0.79

First public release of Valora.

- Added local-first asset lifecycle management with serving, retired, sold, and archived states.
- Added wish lists, analytics, export, backup, optional WebDAV / Nextcloud / JianGuoYun sync, and Android widgets.
- Prepared public project metadata, open-source documentation, Apache-2.0 license, NOTICE, contribution guide, security policy, and GitHub Actions checks.
