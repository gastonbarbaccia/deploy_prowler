output "ec2_public_ip" {
  value = "http://${aws_instance.ec2.public_ip}:3000"
}
