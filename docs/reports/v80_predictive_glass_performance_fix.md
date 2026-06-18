# V80 predictive back, liquid glass and onboarding stability patch

- Predictive back: settings route visual layer now has a more refined edge glow, rounded-page scale and shadow motion instead of a plain horizontal slide.
- Liquid glass: Dock/add/save lenses use `shapeRefraction`, stronger optical border, lower blur, higher distortion band and device refresh capture while keeping only scene-level LiquidGlassView instances.
- Performance: ordinary small controls stay on the classic lightweight Gaussian glass fallback; shell and editor backgrounds are wrapped in RepaintBoundary before being captured by LiquidGlassView.
- First-launch onboarding: auto-start now waits for the real home overview target to be stable across consecutive polls, retries if it is not ready, and ignores accidental early close callbacks during the first 1.5 seconds.
- Version remains 0.80 / build 80.
