# Import input variables
variable dns_rg_name    {}
variable dns_ttl        {}
variable dns_zone_name  {}

variable fd_name        {}
variable fd_cert_check  {}
variable fd_http_port   {}
variable fd_https_port  {}
variable fd_lb_name     {}
variable fd_pip_name    {}
variable fd_probe_name  {}
variable fd_rg_name     {}
variable fd_region      {}
variable fd_routes      {}

# Create a list of endpoints for the defined routes to simplify resource blocks
locals {
    endpoint_list = flatten([
        for route in var.fd_routes: [
            for endpoint in route.endpoints: endpoint
        ]
    ])
}

# The public IP isn't actually used as we are not serving content
resource azurerm_public_ip public_ip {
  name                                         = var.fd_pip_name
  location                                     = var.fd_region
  allocation_method                            = "Static"

  resource_group_name                          = var.fd_rg_name
}

# CNAMEs records are used to provide compabibility for non-Azure apps; loop over Endpoints
resource azurerm_dns_cname_record record {
    for_each                 = { for e in local.endpoint_list: e => e }    
   
    name                     = each.value
    record                   = "${var.fd_name}.azurefd.net"
    ttl                      = var.dns_ttl
    zone_name                = var.dns_zone_name

    resource_group_name      = var.dns_rg_name
}

# Create the actual Frontdoor
resource azurerm_frontdoor frontdoor {
    name                                         = var.fd_name
    enforce_backend_pools_certificate_name_check = var.fd_cert_check
    
    resource_group_name                          = var.fd_rg_name

    backend_pool_load_balancing {
        name                                     = var.fd_lb_name
    }

    backend_pool_health_probe {
        name                                     = var.fd_probe_name
    }

    backend_pool {
        name                                     = azurerm_public_ip.public_ip.name 

        backend {
            host_header                          = azurerm_public_ip.public_ip.ip_address
            address                              = azurerm_public_ip.public_ip.ip_address
            http_port                            = var.fd_http_port
            https_port                           = var.fd_https_port
        }

        load_balancing_name                      = var.fd_lb_name
        health_probe_name                        = var.fd_probe_name
    }

    frontend_endpoint {
        name                                    = "default"
        host_name                               = "${var.fd_name}.azurefd.net"
    }

    # Loop over endpoints
    dynamic frontend_endpoint {
        for_each                                 = { for e in local.endpoint_list: e => e }
        
        content {
            name                                 = frontend_endpoint.value
            host_name                            = "${frontend_endpoint.value}.${var.dns_zone_name}"
        }
    }

    # Loop over the top-level route keys
    dynamic routing_rule {
        for_each                                 = keys(var.fd_routes)
                
        # Accepted protcools, patterns_to_match, redirect_protocol and redirect type could be easily ported to tfvars
        content {
            name                                 = routing_rule.value
            accepted_protocols                   = ["Http", "Https"]
            patterns_to_match                    = ["/*"]
            frontend_endpoints                   = lookup(var.fd_routes, routing_rule.value).endpoints
        
            redirect_configuration {
                custom_host                      = lookup(var.fd_routes, routing_rule.value).host
                custom_path                      = lookup(var.fd_routes, routing_rule.value).path
                redirect_protocol                = "MatchRequest"
                redirect_type                    = "Found"
            }
        }
    } 
}
