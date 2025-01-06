# Tailscale Docker Stack Deploy Action

This simple action deploys a Docker stack to a remote Docker host using the Tailscale VPN.

## Configure Remote Access for Docker Daemon

1. Adding the `daemon.json` file:
   ```bash
   sudo nano /etc/docker/daemon.json
   ```
   Add the following configuration to the file:
   ```json
   {
     "hosts": ["unix:///var/run/docker.sock", "tcp://<your-100.xxx.ip>:2375"]
   }
   ```
   > **Note**: You can also use the `0.0.0.0` IP address to bind to all interfaces or the Tailscale IP range. Read more about it [here](https://docs.docker.com/engine/daemon/remote-access/).

2. Edit the `docker.service` file:
   ```bash
   sudo nano /usr/lib/systemd/system/docker.service
   ```
   Replace the `-H fd://` from the `ExecStart` line:
   ```shell
   /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
   ```
   with:
   ```shell
   /usr/bin/dockerd --containerd=/run/containerd/containerd.sock
   ```

3. Reload the `systemctl` configuration:
   ```bash
   sudo systemctl daemon-reload
   ```

4. Restart the Docker service:
   ```bash
   sudo systemctl restart docker.service
   ```

5. Verify that the changes have been applied:
   Install `netstat` if it's not already installed:
   ```bash
   sudo apt install net-tools
   ```
   Then check:
   ```bash
   sudo netstat -lntp | grep dockerd
   ```
   Example output:
   ```
   tcp        0      0 127.0.0.1:2375          0.0.0.0:*               LISTEN      3758/dockerd
   ```

## Set Up Docker Engine in Swarm Mode

1. Initialize swarm mode:
   ```bash
   docker swarm init
   ```

2. Configure the advertise address:
   ```bash
   docker swarm init --advertise-addr <MANAGER-IP (your-public-ip or your-private-ip)>
   ```

## Inputs

| Input          | Required | Default               | Description                          |
|----------------|----------|-----------------------|--------------------------------------|
| tailscale_host | true     |                       | Tailscale host of the Docker host    |
| docker_port    | false    | 2375                  | Docker daemon port                   |
| compose_file   | false    | docker-compose.yaml   | Docker Compose file                  |
| stack_name     | true     |                       | Docker stack name                    |
| env_file       | false    |                       | Environment file                     |
| custom_flags   | false    |                       | Custom flags for `docker stack deploy` |
| github_token   | false    |                       | GitHub token for authentication with GitHub Container Registry |

## Example Usage

```yaml
steps:
  - name: Deploy Docker Stack
    uses: xfathurrahman/tailscale-docker-stack-deploy@v1.4.0
    with:
      tailscale_host: ${{ secrets.TS_HOST }}
      stack_name: my_docker_stack
      github_token: ${{ secrets.GITHUB_TOKEN }}
      compose_file: docker-compose.override.yaml
      custom_flags: "--with-registry-auth"
```

- `${{ secrets.TS_HOST }}`: The Tailscale host of the Docker host where the stack will be deployed (e.g., the Tailscale machine hostname or IP address like `100.xxx.xxx.xxx`).
- `${{ secrets.GITHUB_TOKEN }}`: Required when using a private image from GitHub Container Registry.

## Notes

The optional `custom_flags` input can be used to pass additional options to the `docker stack deploy` command. For example:
- `--with-registry-auth`: Use registry authentication credentials.
- `--prune`: Apply changes and remove services that are no longer defined.

Ensure that your Docker host is correctly configured for remote access before using this action.