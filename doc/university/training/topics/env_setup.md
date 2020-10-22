---
comments: false
---

# Configure your environment

## Install

- **Windows**
  - Install 'Git for Windows' from <https://gitforwindows.org>

- **Mac**
  - Type '`git`' in the Terminal application.
  - If it's not installed, it will prompt you to install it.

- **Linux**
  
  - Type `which git` in the Terminal application and hit enter. If the output of that command gives you the path to the git executable, which looks something like `/usr/bin/git`, then you have git already installed on your system.
  
  - If git isn't installed on your system, you will recieve an error reporting to you that the command that you tried to execute was not found. 
  
  - The easiest way to install git would be using the default package manager of the distribution you are using. Given below are commands to install git on various GNU/Linux distributions using their default package managers. Run the command corresponding to your distribution and once the installation process is completed you should be able to use git on your system.

  - Archlinux and it's derivatives.

    ```shell
    sudo pacman -S git
    ```
  - Fedora/RHEL/CentOS
    - Using `yum` package manager:
  
    ```shell
    sudo yum install git-all
    ```
  
    - Using `dnf` package manager:
  
    ```shell
    sudo dnf install git
    ```

  - Debian/Ubuntu and their derivatives: 
  
    ```shell
    sudo apt-get install git
    ```
    
  - Gentoo
  
    ```shell
    sudo emerge --ask --verbose dev-vcs/git
    ```

  - openSUSE
    
    ```shell
    sudo zypper install git
    ```

- **FreeBSD**
  
  ```shell
  sudo pkg install git
  ```

- **OpenBSD**

  ```shell
  doas pkg_add git
  ```

## Configure Git

One-time configuration of the Git client

```shell
git config --global user.name "Your Name"
git config --global user.email you@example.com
```

## Configure SSH Key

```shell
ssh-keygen -t rsa -b 4096 -C "you@computer-name"
```

```shell
# You will be prompted for the following information. Press enter to accept the defaults. Defaults appear in parentheses.
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/you/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /Users/you/.ssh/id_rsa.
Your public key has been saved in /Users/you/.ssh/id_rsa.pub.
The key fingerprint is:
39:fc:ce:94:f4:09:13:95:64:9a:65:c1:de:05:4d:01 you@computer-name
```

Copy your public key and add it to your GitLab profile

```shell
cat ~/.ssh/id_rsa.pub
```

```shell
ssh-rsa AAAAB3NzaC1yc2EAAAADAQEL17Ufacg8cDhlQMS5NhV8z3GHZdhCrZbl4gz you@example.com
```
