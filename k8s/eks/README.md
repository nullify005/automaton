# EKS Getting Started Guide Configuration

This is the full configuration from https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

See that guide for additional information.

NOTE: This full configuration utilizes the [Terraform http provider](https://www.terraform.io/docs/providers/http/index.html) to call out to icanhazip.com to determine your local workstation external IP for easily configuring EC2 Security Group access to the Kubernetes master servers. Feel free to replace this as necessary.

## Notes

* The default AWS CNI _will_ have pod limitations because of max CNI per instance
  depending on type. Because of this I think we should probably avoid it
* Scaling in a node pool to 0 appears to be pretty difficult with EKS ... the TF and
  the admin UI screens basically stop you from going lower than 1. You also can't use
  the eksctl to fiddle with it because it uses cloud formation under the hood
* Consider using the Weave CNI ... the Calico impl in EKS isn't using bird or even
  vxlan, so though it'll give policies I'm not certain there's much of a point
* The native service mesh isn't compatible with anything else so any service mesh type
  policies we'd roll out would be vendor locked to the EKS / App Mesh implementation
* You have to run https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
  in order to sort out scaling
* https://blog.gruntwork.io/comprehensive-guide-to-eks-worker-nodes-94e241092cbe
