# Hot Deployments in Ballerina

Hot deployment enables zero-downtime updates by running multiple Ballerina instances behind an NGINX load balancer. This approach allows you to update applications without service interruption by maintaining at least one healthy instance at all times.

## Deployment Strategies

Choose the right strategy based on your requirements and available tools.

### 1. Active-Active without Health Checks

In this setup, all instances actively handle traffic. NGINX monitors instance health passively using the `max_fails` and `fail_timeout` directives. If a server fails a request `max_fails` times within the `fail_timeout` window, it is temporarily marked as unavailable.

Failed requests are automatically retried on other available instances, as a fault tolerance mechanism.

```nginx
events {}

http {
    upstream backend {
        server 127.0.0.1:8080 max_fails=3 fail_timeout=30s;
        server 127.0.0.1:8081 max_fails=3 fail_timeout=30s;
    }

    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}
```

### 2. Active-Active with Health Checks

This configuration requires NGINX Plus, which supports active health checks. NGINX proactively polls a specified health endpoint (e.g., /health) on each instance to determine availability.

```nginx
events {}

http {
    upstream backend {
        server 127.0.0.1:8080 max_fails=3 fail_timeout=30s;
        server 127.0.0.1:8081 max_fails=3 fail_timeout=30s;
    }

    server {
        listen 80;
        location / {
            proxy_pass http://backend;
            health_check uri=/health interval=5s;
        }
    }
}
```

### 3. Active-Passive

Primary server handles all traffic, backup only activates on failure. The backup server remains idle until the primary fails, ensuring you always have a clean failover target.

```nginx
events {}

http {
    upstream backend {
        server 127.0.0.1:8080 max_fails=3 fail_timeout=30s;
        server 127.0.0.1:8081 max_fails=3 fail_timeout=30s backup;
    }

    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}
```

## Setup Guide

To test this locally you can run several Ballerina services parallely and set the relevant uri in the NGINX configurations.

```ballerina
import ballerina/http;

configurable int port = 8080;

service / on new http:Listener(port) {
    resource function get .() returns json {
        return {"message": "Request received", "port": port};
    }
    
    resource function get health() returns json {
        return {"status": "running", "port": port};
    }
}
```

## Quick Tips

Key NGINX parameters and best practices for reliable hot deployments:

- **max_fails=3**: Mark server down after 3 failures
- **fail_timeout=30s**: Keep server down for 30 seconds
- **backup**: Only use when primary fails
- **health_check**: Requires NGINX Plus for active monitoring
- Always test configuration: `nginx -t`
