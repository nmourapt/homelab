# Portainer Stacks

Docker Compose stacks deployed to Portainer via Terraform.

## Structure

```
portainer/
├── stacks/           # Docker Compose files and environment configs
│   └── <service>/
│       ├── docker-compose.yml
│       └── <service>.env      # SOPS-encrypted environment variables
└── terraform/        # Terraform configs for deploying stacks
    ├── <service>.tf           # Stack resource definition
    ├── network.tf             # Docker networks
    └── provider.tf            # Portainer provider config
```

## Adding a New Service

1. **Create stack directory:**
   ```bash
   mkdir -p portainer/stacks/myservice
   ```

2. **Add Docker Compose file:**
   ```yaml
   # portainer/stacks/myservice/docker-compose.yml
   services:
     myservice:
       image: myimage:latest
       environment:
         - SECRET_KEY=${SECRET_KEY}
   ```

3. **Add encrypted environment file:**
   ```bash
   # Create and encrypt env file
   sops portainer/stacks/myservice/myservice.env
   ```

4. **Add Terraform resource:**
   ```hcl
   # portainer/terraform/myservice.tf
   resource "portainer_stack" "myservice_stack" {
     name             = "myservice"
     deployment_type  = "compose"
     method           = "string"
     endpoint_id      = 2
     stack_file_path  = "${path.module}/../stacks/myservice/docker-compose.yml"
   }
   ```

5. **Push changes** - GitHub Actions will deploy automatically.

## Environment Variables

Environment files use SOPS encryption with age. The CI/CD pipeline:

1. Decrypts `.env` files using the `SOPS_AGE_KEY` secret
2. Substitutes `${VAR}` placeholders in docker-compose.yml
3. Deploys the processed compose file to Portainer

## Networks

Shared Docker networks are defined in `terraform/network.tf`:

- Services can reference these networks in their compose files
- Networks are created before stacks are deployed

## State Backend

Terraform state is stored in Cloudflare R2 (same as Cloudflare config).

## Deployment

Automatically deployed via GitHub Actions when changes are pushed to:
- `portainer/terraform/*.tf`
- `portainer/stacks/**/*.yml`
- `portainer/stacks/**/*.env`

See `.github/workflows/deploy-stacks.yml`.
