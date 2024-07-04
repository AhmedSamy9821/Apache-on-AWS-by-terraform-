# Apache Server on AWS using Terraform

This project demonstrates how to set up an Apache server infrastructure on AWS using Terraform. The architecture includes two application load balancers, Nginx proxy servers, and Apache servers, as depicted in the **Project diagram.png**.

## Architecture Overview

![Project Diagram](Project%20diagram.png)

The infrastructure consists of:

1. **Internet-Facing Load Balancer**:
   - Forwards incoming traffic to two Nginx servers located in public subnets.

2. **Nginx Servers**:
   - Act as proxies to forward the traffic to the second load balancer.
   - Ensure secure traffic routing.

3. **Internal Load Balancer**:
   - Forwards the traffic from the Nginx servers to two Apache servers located in private subnets.

4. **Apache Servers**:
   - Handle the application traffic in a secure manner.

## Security Considerations

- The use of an internet-facing load balancer ensures that only authorized traffic reaches the Nginx servers.
- Nginx servers, acting as proxies, add an additional layer of security by filtering and forwarding the traffic to the internal load balancer.
- The internal load balancer ensures that traffic is securely routed to the Apache servers in private subnets, which are not directly accessible from the internet.

## Prerequisites

- AWS Account
- Terraform installed
- AWS CLI configured with appropriate permissions
