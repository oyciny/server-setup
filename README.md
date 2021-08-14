# Initial Server Setup Helper Script

The point of this script is to simplify the server setup process. It will continue to progress over time with new features. Right now I am looking into adding a menu similar to this:

1\) Initial Server Setup\n
2\) Install Nginx\n
3\) Install Docker\n
4\) Setup Node App from Git Repo\n
5\) Exit\n

I want a setup script that automates the tasks I hate doing over and over again. With every new VM you have to follow the same steps you've followed 1000 times over and nobody likes that kind of repetition.

## Installation
To get started using the script simply use the following commands:

	> curl -O https://raw.githubusercontent.com/oyciny/server-setup/main/server-setup.sh
	> chmod +x server-setup.sh
	> ./server-setup.sh
This will download the script to your server and run it for you.

## Planned Features
 - Nginx Setup
 - Docker Setup
 - Single Node App Setup