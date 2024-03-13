#!/usr/bin/bash
# https://www.cyberciti.biz/security/how-to-unlock-luks-using-dropbear-ssh-keys-remotely-in-linux/
# needs sudo
# Dropbear decrypt need this stupid -o flag `ssh -o "HostKeyAlgorithms ssh-rsa" -p 2222 root@192.168.0.0`
apt install dropbear-initramfs
CONF="/etc/dropbear/initramfs/dropbear.conf"
sd '#DROPBEAR_OPTIONS=""' 'DROPBEAR_OPTIONS="-I 180 -j -k -p 2222 -s -c cryptroot-unlock"' $CONF
# echo 'IP=192.168.2.19::192.168.2.254:255.255.255.0:debian' > $CONF

P="/etc/dropbear/initramfs"
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFtOoE+UsKcjaWezmo7tIQnRjbO6D0MxVug5gCr15u1LYrE1Sxc0YjmR+6hqmX+0NiQEntbSBscTEbcjsl7TaaO70HKQqgcQ1Wq0BFzrXN/FrZKE1gWHR/dreupqNVkOIxTuXt6kr8vJ8fgh9NH9phQr9TWUt+YIj5f7d8883NkD1LUW+OI6IoE7rJPVd0vjJfMRQHrqFXzSrkymTcuciAqzJnnMMQQQe/VgWoTlH6s828UcWSDUa63/IxdLWoV2k2IcKMS18E7eFxeXZNU6z0ritP05auWUSMa0nm/Az4ptrqopW9C2G0biY8NVOUwk4DgKxXppniEOnR70wua5zYeUETSYo5TvvahQd621bttLSEf65CHFgceGy91tNmDOTTG8NM9Msil8i/x6tWKpiJZzWn1W25SZpaQmHGdLwDrwWFU21SgGMnT8LjfsU4cBu3JFkwQ59JyEqKmp/Nqdjp70UyLxxPiLpDmfSVFtHYA/p5ikAxLncRE+Bmq5R3Cz8= user@fedora' > $P/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1Rfkw5wRT20w/ctaMwI2EQkCxBmuRcG40hF+UrKTtWINJ+ddDEq+Np6QA9CU+7DD9QsfRcXrIxHiMgQ/P7NOpoTAEcSJu+T15GQcFAIxgU8av2UBK84zlxLOrjkpHwhowMiOCvF0fWz+n84/bW1/qAnb49Xbd6rBkCEX274hpJvTf6UrxzvagM20GLON8N+2KSBEyWctYfFMx3QrKwToJNg6t3kjE4G/x8lIAk09IvTagi4aVvuTRQYIOm0if+yX2bUBLQGsJZDPL4mWGqYl8+MmQ3ufgKEHH7Dfm2u7V7zyHvs/KnEylBV6r1e4BImPqHyl7eLWSNCA7dCAGAzOyjUCgo/hZLUXO2d3LKDRuQ7L6PwdPd89VxpIbhgmFbXl+Wg2ezAz/GVFYlzlEx99ExLdATIqxKV5hop6LeFVQhvv8rzNTTXvXlu9P5oy87Lq11LPKWc+EXxgVv4jiiIK0iS2tmAbVH12owwaCqF1Lo99klqw1BETZCmQvgu5yIP8= homelab-master id_rsa_pub' >> $P/authorized_keys

update-initramfs -u

