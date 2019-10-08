# kops

## AWS and MFA

When using kops you cannot use MFA with AWS cli tooling

Use `aws sts assumerole`

* https://github.com/kubernetes/kops/blob/master/docs/mfa.md

## kube context

In order for kops to be happy when running kubectl commands the context
_must_ match the cluster name as defined in kops
