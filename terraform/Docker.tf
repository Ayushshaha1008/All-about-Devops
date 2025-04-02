# This is actually incomplete script and may not run

provider "aws" {
    region = "eu-north-1"

}   
resource "aws_security_group" "OG" {
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
     ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "Docker" {
    ami = "ami-0c1ac8a41498c1a9c"

    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.OG.id]
    user_data = <<EOT
#!/bin/bash
set -e  # ✅ Exit script on error

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Remove old versions of Docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
  sudo apt-get remove -y $pkg || true
done

# Install dependencies
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$${UBUNTU_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Create project directory
mkdir -p /home/ubuntu/Project

# Create Dockerfile
cat <<EOF > /home/ubuntu/Project/Dockerfile
FROM amazonlinux:latest
RUN yum install httpd -y
RUN echo "hi this is homepage" > /var/www/html/index.html
EXPOSE 80
CMD [ "/usr/sbin/httpd", "-D", "FOREGROUND" ]
EOF

# Set permissions
sudo chown -R ubuntu:ubuntu /home/ubuntu/Project
EOT


  
}