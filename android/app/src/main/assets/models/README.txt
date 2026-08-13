This directory is a reserved slot for optional offline sticker-segmentation
.tflite models in a future version. The current APK does not ship a local
TFLite model here: automatic subject segmentation uses ML Kit, reports its
downloading/ready/unavailable state, and falls back to an offline heuristic
contour when the ML Kit model is unavailable.
