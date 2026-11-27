# Landing-zone networking

## Purpose

This fictional standard describes network defaults for an internal architecture POC.

## Requirements

- Place related application resources in the approved environment resource group and region.
- Require HTTPS and TLS 1.2 or newer for service endpoints.
- Keep storage containers private; never enable anonymous blob access.
- Authenticate service-to-service calls with Microsoft Entra ID and managed identities.
- Public endpoints may be used for a short-lived learning POC when network controls are not yet provisioned. Restrict access before handling sensitive or production data.
- Production workloads must use the organization's approved virtual network and private connectivity pattern.

## Review

Document any public endpoint, ingress path, or cross-region dependency in the deployment review. A resource group's metadata location does not force every child resource to use that region, but this POC intentionally keeps billable resources in one region.