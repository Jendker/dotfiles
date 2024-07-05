In /etc/ssh/sshd_config.d/100-macos.conf add the following lines to disable password authentication:
```
PasswordAuthentication no
ChallengeResponseAuthentication no
```
