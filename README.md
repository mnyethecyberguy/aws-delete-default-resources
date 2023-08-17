# aws-delete-default-resources

This bash shell script is configured to delete the defaul VPCs and associated resources.  Can be particularly useful when creating a new AWS account to eliminate insecure default configurations in your environment.

## Dependencies
- `awscliv2` installed and configured with a default profile
- `jq` (for parsing JSON output from AWS CLI commands)