# Claude Code Docker Setup

This setup runs Claude Code on a Claude Max or Pro subscription entirely in Docker with credentials stored in a Docker volume.

## Quick Start

1. **Initial Setup & Login**
   ```bash
   ./setup
   ```
   This will:
   - Create a Docker volume `claude_config`
   - Build the Docker image
   - Run the OAuth login process inside the container
   - Store credentials in the Docker volume

2. **Run Claude Code**
   ```bash
   ./run
   ```
   Or directly:
   ```bash
   docker run --rm -it -v $(pwd):/workspace -v claude_config:/home/claude/.claude claude_max
   ```

3. **Refresh Tokens**
   ```bash
   ./refresh
   ```

4. **Clean Everything**
   ```bash
   ./clean
   ```
   This removes the Docker image, volume, and any containers.

## Files

- `setup` - Initial setup and login
- `run` - Run Claude Code
- `refresh` - Refresh OAuth tokens
- `clean` - Remove everything
- `Dockerfile` - Docker image definition
- `login_*.rb`, `refresh_token.rb` - OAuth scripts (run inside container)

## Architecture

- All credentials are stored in Docker volume `claude_config`
- Login happens inside the container
- Current directory is mounted as `/workspace` when running Claude Code
