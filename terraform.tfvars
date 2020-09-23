# Provider
subscription_id              = ""
client_id                    = ""
tenant_id                    = ""
client_secret                = ""

# Azure DNS 
dns_ttl                      = 86400    
dns_zone_name                = ""       # Name of the DNS Zone, ex. my.fqdn
dns_rg_name                  = ""       # Name of the resource group for DNS

# Frontdoor
fd_name                      = ""       # Name of the instance (also public name)
fd_cert_check                = false    # Whether or not to check SSL certificates
fd_http_port                 = 80       # Port for HTTP
fd_https_port                = 443      # Port for HTTPS
fd_lb_name                   = ""       # Name of the load balancing poool
fd_pip_name                  = ""       # Name of the public IP address
fd_probe_name                = ""       # Name of the pool probe
fd_region                    = ""       # Name of the Azure region, ex. "East US2"
fd_rg_name                   = ""       # Name of the resource group for Frontdoor

# A map containing routes and associated configuration
fd_routes = {
    # Name of the route
    mfa = {
        # Endpoints for DNS and front-end
        endpoints = ["mfa", "mfasetup", "three"]
        # FQDN for the destination host name
        host      = "aka.ms"
        # Path on the destination host
        path      = "/mfasetup"
    }
}