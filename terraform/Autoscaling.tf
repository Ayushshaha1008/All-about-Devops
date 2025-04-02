

provider "aws" {
  region = "eu-north-1"

}
resource "aws_vpc" "Ayush" {
  cidr_block       = "10.0.0.0/16"
  tags = {
  name = "Ayush"
  }
}
resource "aws_subnet" "main" {

  vpc_id = aws_vpc.Ayush.id
  map_public_ip_on_launch = true
  cidr_block     = "10.0.0.0/24"
  availability_zone=  "eu-north-1a"
}
resource "aws_subnet" "main2" {

  vpc_id = aws_vpc.Ayush.id
  map_public_ip_on_launch = true
  cidr_block     = "10.0.16.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Ayush.id

  tags = {
    Name = "my-igw"
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.Ayush.id
   

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table" "example2" {
  vpc_id = aws_vpc.Ayush.id
   

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.example.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.main2.id
  route_table_id = aws_route_table.example2.id
  }
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.Ayush.id
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

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Sg-group"
  }
}
resource "aws_instance" "home" {
    ami                     = "ami-0c2e61fdcb5495691"
    instance_type           = "t3.micro"
    subnet_id     = aws_subnet.main.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    user_data = <<EOF
   
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
systemctl enable httpd
cd /var/www/html
cat <<HTML >index.html
<html><head>
<title>Welcome to My Store</title>
<link rel="stylesheet" type="text/css" href="style.css">
<style>
body {
font-family: Arial, sans-serif;
background: linear-gradient(135deg, #ff9a9e, #fad0c4);
text-align: center;
color: #fff;
padding: 50px;

h1 {
font-size: 48px;
text-shadow: 3px 3px 10px rgba(0, 0, 0, 0.2);
}
nav {
margin-top: 20px;
}
nav a {
text-decoration: none;
font-size: 24px;
color: #fff;
background: rgba(0, 0, 0, 0.2);
padding: 15px 30px;
border-radius: 10px;
margin: 10px;
display: inline-block;
transition: 0.3s;
}
nav a:hover {
background: rgba(0, 0, 0, 0.5);
transform: scale(1.1);
}
</style>
</head>
<body>
<h1>Welcome to My Store 🏪</h1
<nav>
<a href="/mobile/">📱 Mobile Section</a>
<a href="/laptop">💻 Laptop Section</a>
</nav>
</body>
</html>
HTML
systemctl restart httpd
EOF

  tags = {
    Name = "Home"
  }
    }
resource "aws_instance" "mobile" {
    ami                     = "ami-0c2e61fdcb5495691"
    instance_type           = "t3.micro"
    subnet_id     = aws_subnet.main.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    user_data = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
systemctl enable httpd
mkdir /var/www/html/mobile
cd /var/www/html/mobile
cat <<HTML>index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mobile Category</title>
</head>
<body>
<h1>Welcome to the Mobile Section</h1>
<p>Explore the latest mobile phones here!</p>
</body>
</html>
HTML
systemctl restart httpd
EOF
 tags = {
    Name = "Mobile"
  }
}
resource "aws_instance" "laptop" {
    ami                     = "ami-0c2e61fdcb5495691"
    instance_type           = "t3.micro"
    subnet_id     = aws_subnet.main.id
    vpc_security_group_ids = [aws_security_group.sg.id]
    user_data = <<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
systemctl enable httpd
mkdir /var/www/html/laptop
cd /var/www/html/laptop
cat <<HTML > index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Laptop Category</title>
</head>
<body>
<h1>Welcome to the Laptop Section</h1>
<p>Find the best laptops here!</p>
</body>
</html>"
> index.html
HTML
systemctl restart httpd
EOF
 tags = {
    Name = "Laptop"
    }
}
resource "aws_lb_target_group" "Home" {
  name     = "Home"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.Ayush.id
   health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"  # Ensures only HTTP 200 is considered healthy
  }
}

resource "aws_lb_target_group_attachment" "Home" {
    target_group_arn = aws_lb_target_group.Home.arn
    target_id = aws_instance.home.id
}
resource "aws_lb_target_group" "Mobile" {
  name     = "Mobile"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.Ayush.id
}
resource "aws_lb_target_group_attachment" "Mobile" {
    target_group_arn = aws_lb_target_group.Mobile.arn
    target_id = aws_instance.mobile.id
}
resource "aws_lb_target_group" "Laptop" {
  name     = "Laptop"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.Ayush.id
}
resource "aws_lb_target_group_attachment" "laptop" {
    target_group_arn = aws_lb_target_group.Laptop.arn
    target_id = aws_instance.laptop.id
}
resource "aws_lb" "test"{
    name = "ALB"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.sg.id ]
    subnets = [ aws_subnet.main.id , aws_subnet.main2.id]
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.id
  port              = "80"
  protocol          = "HTTP"
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Home.arn
  }
  }
resource "aws_lb_listener_rule" "Mobile"{
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 1
    action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Mobile.arn
  }
    condition {
      path_pattern {
      values = ["/mobile/*"]
    } 
}
}
resource "aws_lb_listener_rule" "Laptop"{
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 2
    action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Laptop.arn
  }
    condition {
      path_pattern {
      values = ["/laptop/*"]
    }
}
}
resource "aws_launch_template" "home" {
  name = "home"
  instance_type = "t3.micro"
  image_id = "ami-0c2e61fdcb5495691"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data =base64encode(
<<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
systemctl enable httpd
cd /var/www/html
cat <<HTML >index.html
<html><head>
<title>Welcome to My Store</title>
<link rel="stylesheet" type="text/css" href="style.css">
<style>
body {
font-family: Arial, sans-serif;
background: linear-gradient(135deg, #ff9a9e, #fad0c4);
text-align: center;
color: #fff;
padding: 50px;

h1 {
font-size: 48px;
text-shadow: 3px 3px 10px rgba(0, 0, 0, 0.2);
}
nav {
margin-top: 20px;
}
nav a {
text-decoration: none;
font-size: 24px;
color: #fff;
background: rgba(0, 0, 0, 0.2);
padding: 15px 30px;
border-radius: 10px;
margin: 10px;
display: inline-block;
transition: 0.3s;
}
nav a:hover {
background: rgba(0, 0, 0, 0.5);
transform: scale(1.1);
}
</style>
</head>
<body>
<h1>Welcome to My Store 🏪</h1
<nav>
<a href="/mobile">📱 Mobile Section</a>
<a href="/laptop">💻 Laptop Section</a>
</nav>
</body>
</html>
HTML
systemctl restart httpd
EOF
)
tags = {
  Name = "Home"
}
}
resource "aws_launch_template" "Mobile" {
  name = "Mobile"
  instance_type = "t3.micro"
  image_id = "ami-0c2e61fdcb5495691"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data =base64encode(<<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
systemctl enable httpd
mkdir /var/www/html/mobile
cd /var/www/html/mobile
cat <<HTML>index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Mobile Category</title>
</head>
<body>
<h1>Welcome to the Mobile Section</h1>
<p>Explore the latest mobile phones here!</p>
</body>
</html>
HTML
systemctl restart httpd
EOF
)
tags = {
  Name = "Mobile"
}
  }
resource "aws_launch_template" "Laptop" {
  name = "Laptop"
  instance_type = "t3.micro"
  image_id = "ami-0c2e61fdcb5495691"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data =base64encode(<<EOF
#!/bin/bash
sudo -i
yum install httpd -y
systemctl start httpd
systemctl enable httpd
mkdir /var/www/html/laptop
cd /var/www/html/laptop
cat <<HTML > index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Laptop Category</title>
</head>
<body>
<h1>Welcome to the Laptop Section</h1>
<p>Find the best laptops here!</p>
</body>
</html>
HTML
systemctl restart httpd
EOF
  )
 tags = {
    Name = "Laptop"
    }
  }
  resource "aws_autoscaling_group" "Home" {

  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.home.id
    version = "$Latest"
  }
  target_group_arns = [ aws_lb_target_group.Home.arn ]
  vpc_zone_identifier = [aws_subnet.main.id , aws_subnet.main2.id]
  
}
resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "cpu-scale-up"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.Home.id

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
resource "aws_autoscaling_group" "Mobile" {

  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.Mobile.id
    version = "$Latest"
  }
  target_group_arns = [ aws_lb_target_group.Mobile.id ]
  vpc_zone_identifier = [aws_subnet.main.id , aws_subnet.main2.id]
  
}
resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "cpu-scale-up"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.Mobile.id

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
resource "aws_autoscaling_group" "Laptop" {

  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
    id      = aws_launch_template.Laptop.id
    version = "$Latest"
  }
  target_group_arns = [ aws_lb_target_group.Laptop.id ]
  vpc_zone_identifier = [aws_subnet.main.id , aws_subnet.main2.id]
  
}
resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "cpu-scale-up"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.Laptop.id

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
} 