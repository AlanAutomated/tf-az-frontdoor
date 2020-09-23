# Azure Frontdoor Terraform template

This template creates an Azure Frontdoor and the associated Azure DNS records for a DNS-based URL redirection service. This is a cost effective and highly available alternative to using Traffic Manager and Functions or similar solutions combination of services.


## Example Usage
This example creates a DNS entry for http(s)://mfa.my.fqdn and http(s)://mfasetup.my.fqdn that when accessed redirects to http(s)://aka.ms/mfasetup.

````
# Map of Frontdoor routes
fd_routes = {

    # The name of an individual route
    mfa = {
        # Endpoints associated with the route. CNAME records will also be created.
        endpoints = ["mfa", "mfasetup" ]
    
        # FQDN for the redirected host
        host      = "aka.ms"
        
        # Path for the rediected host path
        path      = "/mfasetup"
    }
}
````
