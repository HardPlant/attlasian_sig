
variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
  default = "/home/seongwon/repo/atlassian_sig/id_rsa.pub"
}
variable "key_name" {
  default = "ConfJira2"
}