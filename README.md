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