# Security Policy

Valora stores personal asset records, cover media, backup files and optional WebDAV configuration. Please treat privacy and local data safety as first-class concerns.

## Reporting a Vulnerability

If you find a vulnerability, please do not publish exploit details before the project maintainer has time to respond.

For now, use a private GitHub security advisory after the repository is published. If security advisories are not enabled yet, open a minimal public issue that says a private security report is needed, without including secrets, exploit steps, personal data or private server addresses.

## Sensitive Areas

Please pay extra attention to changes touching:

- Backup export, restore and ZIP handling.
- SQLite migrations or local data deletion.
- WebDAV / Nextcloud / Jianguoyun configuration.
- Android file sharing, `FileProvider`, camera, OCR, notifications and widgets.
- Any code path that handles images or generated media.

## Supported Versions

Until the first public release is tagged, security fixes target the latest `main` branch only.
