# Usage Patterns

Various usage patterns are prescribed below.

## Common Patterns
There are several common patterns to use with the alb for example:              
1. Redirect http to https               
2. Configuring Instance Target Group           
3. Return a fixed response              
4. Create several security groups for the load balancer             
5. Create a hosted zone record for the load balancer.           

### Redirect http to https
In the example below we can see a listener with that has a rule to redirect the requests.
The nested blocks of `rules` define the different rules the listener will use. Notice this listener also redirects `http` to `https` before returning the response on the rule.
`ex-http-https-redirect` -> `rules` -> `ex-fixed-response`
```hcl
...
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }

      rules = {
        ex-fixed-response = {
          priority = 3
          actions = [{
            type         = "fixed-response"
            content_type = "text/plain"
            status_code  = 200
            message_body = "This is a fixed response"
          }]

          conditions = [{
            http_header = {
              http_header_name = "x-Gimme-Fixed-Response"
              values           = ["yes", "please", "right now"]
            }
          }]
        }

      }
    }
...
```
### Configuring Instance Target Group
Each nested map defines a target group on the load balancer.                    
The map allows the user to create several targets each with a unique name and the order will remain. In this example `instance_1` and `instance_2` are the target groups.

```hcl
target_groups = {
    instance_1 = {
      name_prefix                       = "h1"
      backend_protocol                  = "HTTP"
      backend_port                      = 80
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = false
    }
    instance_2 = {
      name_prefix                       = "h2"
      backend_protocol                  = "HTTP"
      backend_port                      = 80
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = false
    }

}
```
### Fixed Response
Each nested map defines a listener on the load balancer.                    
The nested map below creates a listener with a fixed response of 200.
`ex-fixed-response`->`fixed_response`                

```hcl
...
listeners ={
    ex-fixed-response = {
      port     = 82
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    }
}
...
```
### Security Groups
Each nested map defines a securtiy group rule. The rules will be created by the module on the same security group
notice we have in the example several nested maps:              
* `security_group_ingress_rules`->`all_http`                
* `security_group_ingress_rules`->`all_https`  
```hcl
...
security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
...
```
### Hosted Zone
Each nested map defines a route53 record.                    
* `A` -> will be an A record and 
* `AAAA` -> will be an AAAA record and 
```hcl
...
  route53_records = {
    A = {
      name    = local.name
      type    = "A"
      zone_id = data.aws_route53_zone.this.id
    }
    AAAA = {
      name    = local.name
      type    = "AAAA"
      zone_id = data.aws_route53_zone.this.id
    }
  }
...
```