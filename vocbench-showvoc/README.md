This directory contains the infrastructure code to deploy VocBench
and ShowVoc locally or remotely.

# Deployment

## Remote

1. Configure version numbers and domain names in `deployment/.env`:
```sh
vim deployment/.env
```

2. Via OVH manager, create a new instance on a public network. Then,
add the associated SSH key to your ssh-agent:
```sh
ssh-add /path/to/ssh/private/key/giving/you/access/to/instance
```

3. Deploy remotely to your instance:
```sh
./deploy-remote.sh <INSTANCE_PUBLIC_IP>
```

4. Via OVH manager, add two DNS "A" records to your DNS zone, to
link your domain names to your instance's public IP.

## Local

Run the deployment script:
```sh
./deploy-local.sh
```

🍺 Done!
