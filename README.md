# Tailscale Docker Stack Deploy Action

This simple action deploys a Docker stack to a remote Docker host using Tailscale VPN.

# Configure remote access for Docker daemon

Adding the docker daemon.json file :
```bash
  sudo nano /etc/docker/daemon.json
```

Add the following config to the file :
```json
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://<your-100.xxx.ip>:2375"]
}
```

#### Note: U can also use the 0.0.0.0 ip address to bind to all interfaces or tailscale ip range. Read more about it [here](https://docs.docker.com/engine/daemon/remote-access/)

Edit the docker.service file :

```bash
  sudo nano /usr/lib/systemd/system/docker.service
```

remove the -H fd:// from the ExecStart line

```
/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

to

```
/usr/bin/dockerd --containerd=/run/containerd/containerd.sock
```

### Reload the systemctl configuration.

```bash
  sudo systemctl daemon-reload
```

### Restart the Docker service.

```bash
  sudo systemctl restart docker.service
```

### Verify that the change has gone through.

install netstat if not installed :
```bash
  sudo apt install net-tools
```

then
    
```bash
  sudo netstat -lntp | grep dockerd
```
```
tcp        0      0 127.0.0.1:2375          0.0.0.0:*               LISTEN      3758/dockerd
```

## Inputs

| Input          | Required | Default               | Description                          |
|----------------|----------|-----------------------|--------------------------------------|
| tailscale_host | true     |                       | Tailscale host of the Docker host    |
| docker_port    | false    | 2375                  | Docker daemon port                   |
| compose_file   | false    | docker-compose.yaml   | Docker Compose File                  |
| stack_name     | true     |                       | Docker Stack Name                    |
| env_file       | false    |                       | Environment File                     |

## Example usage

```yaml
  deploy:
    runs-on: ubuntu-latest
    needs:
      - build-and-push-image
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      # Setup Tailscale VPN
      - name: Setup Tailscale VPN
        id: tailscale
        uses: tailscale/github-action@v2
        with:
          oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
          oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
          tags: tag:ci

      # Create env file
      - name: Create env file
        run: |
          echo "GIT_COMMIT_HASH=${{ github.sha }}" > ./envfile

      # Deploy Docker stack
      - name: Tailscale Docker Stack Deploy
        uses: xfathurrahman/tailscale-stack-deploy-action@v1.2.0
        with:
          tailscale_host: {{ secrets.TS_HOST }} 
          docker_port: "2375"
          compose_file: "docker-stack.yaml"
          stack_name: "stack-name"
          env_file: "./envfile"
```

Note: {{ secrets.TS_HOST }} is the tailscale host of the Docker host where the stack will be deployed. Like the tailscale machine hostname or ip address (100.xxx.xxx.xxx).