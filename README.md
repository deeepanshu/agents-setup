# Agents Setup

Personal setup scripts for coding-agent tooling.

## Pi setup

Pi-specific setup lives in [`pi/`](pi/). The installer is:

```bash
bash pi/install-pi.sh
```

The script installs the Pi CLI and the Pi packages/extensions currently used on this machine, with the Agoda GenAI gateway/proxy intentionally excluded.

No Pi auth files, OAuth tokens, MCP config, model config, caches, or session history are committed to this repository.
