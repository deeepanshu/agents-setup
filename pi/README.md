# Pi setup

Run the installer from the repository root:

```bash
bash pi/install-pi.sh
```

## What it installs

- Pi CLI: latest `@earendil-works/pi-coding-agent` from npm
- Pi packages/extensions:
  - `npm:pi-mcp-adapter@2.8.0`
  - `npm:pi-subagents@0.27.0`
  - `npm:pi-lens@3.8.47`
  - `npm:context-mode@1.0.161`
  - `npm:@juicesharp/rpiv-ask-user-question@1.17.1`
  - `npm:@plannotator/pi-extension@0.19.26` with `skills: []`
  - `npm:pi-web-access@0.10.7`
  - `npm:@juicesharp/rpiv-advisor@1.17.1`
  - `npm:@juicesharp/rpiv-btw@1.17.1`
  - `npm:pi-powerline-footer@0.5.6`
  - `npm:pi-intercom@0.6.0`

## After install

Authenticate Pi separately on each machine:

```bash
pi
/login
```

The installer does not copy secrets or local runtime files such as `auth.json`, OAuth token files, `mcp.json`, `models.json`, caches, or session history.
