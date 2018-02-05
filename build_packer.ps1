Set-Location "C:\Users\Administrator\Documents\bento"

Start-Process -FilePath "cmd" -ArgumentList "/c packer build ubuntu-16.10-amd64.json" -RedirectStandardOutput ubuntu-16.10-amd64.log
Start-Process -FilePath "cmd" -ArgumentList "/c packer build debian-7.11-amd64.json" -RedirectStandardOutput debian-7.11-amd64.log
# Start-Process -FilePath "cmd" -ArgumentList "/c packer build debian-8.7-amd64.json" -RedirectStandardOutput debian-8.7-amd64.log
Start-Process -FilePath "cmd" -ArgumentList "/c packer build centos-6.8-x86_64.json" -RedirectStandardOutput centos-6.8-x86_64.log
# Start-Process -FilePath "cmd" -ArgumentList "/c packer build centos-7.3-x86_64.json" -RedirectStandardOutput centos-7.3-x86_64.log
# Start-Process -FilePath "cmd" -ArgumentList "/c packer build rhel-6.8-x86_64.json" -RedirectStandardOutput rhel-6.8-x86_64.log
# Start-Process -FilePath "cmd" -ArgumentList "/c packer build rhel-7.3-x86_64.json" -RedirectStandardOutput rhel-7.3-x86_64.log
# Start-Process -FilePath "cmd" -ArgumentList "/c packer build sles-12-sp2-x86_64.json" -RedirectStandardOutput sles-12-sp2-x86_64.log
Start-Process -FilePath "cmd" -ArgumentList "/c packer build oracle-6.8-x86_64.json" -RedirectStandardOutput oracle-6.8-x86_64.log
# Start-Process -FilePath "cmd" -ArgumentList "/c packer build oracle-7.3-x86_64.json" -RedirectStandardOutput oracle-7.3-x86_64.log