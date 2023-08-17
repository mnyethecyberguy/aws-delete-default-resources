# aws-delete-default-resources

This bash shell script is configured to delete the default VPCs and associated resources across all enabled regions on your account.  Can be particularly useful when creating a new AWS account to eliminate insecure default configurations in your environment.

## Resources Removed

The following resource objects are removed in all enabled regions:
- DHCP Options
- Internet Gateway (attached to default VPC)
- Subnets (attached to default VPC)
- Security Groups (default)
- Network ACLs (default)
- Route Table (default)

## Dependencies

- `awscliv2` installed and configured with a default profile
- `jq` (for parsing JSON output from AWS CLI commands)
