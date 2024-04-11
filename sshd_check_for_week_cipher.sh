#Setup the variables and ENV.
read -p "Remore_USER name to connect: " _user
read -p "Remote_HOST name to connect: " _host
mkdir -p /tmp/sshdebug/
_logdir="/tmp/sshdebug/"
_log="$_logdir/$_host.$(date +"%Y_%m_%d_%H_%M_%S_%p").log"

#List of outdated Ciphers, MACs and KEX algorithms
_ciphers="aes128-cbc|aes192-cbc|aes256-cbc|blowfish-cbc|cast128-cbc|3des-cbc"
_macs="hmac-sha2-256|hmac-sha2-512|hmac-sha1"
_KEYalgorithms="diffie-hellman-group-exchange-sha1|diffie-hellman-group14-sha1|diffie-hellman-group1-sha1"

#connect to the machine onetime fail/pass does not matter.
tempcon() {
        ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=5 -vvv $_user@$_host 2> $_log
        }

#Storing server and client KEXINIT to temp file to check if outdated ciphers macs KEY offered.
server_client_KEXINIT() {
        grep -A 12 "server KEXINIT proposal" $_log > $_logdir/$_host.server_KEXINIT
        grep -A 12 "client KEXINIT proposal" $_log > $_logdir/$_host.client_KEXINIT
        }
tempcon
server_client_KEXINIT

#capture and print Remote_HOST Ciphers MACs and algorithms.
if [ ! $(egrep -c "$_ciphers|$_macs|$_KEYalgorithms" $_logdir/$_host.server_KEXINIT) -eq 0 ]; then
    echo "Your Remote_HOST [$_host] is offering outdated/unsupported ciphers, macs and KEYalgorithms."
        else
        echo "Your Remote_HOST [$_host] is not offering unsupported ciphers, macs and KEYalgorithms"
fi

#capture and print Local_HOST Ciphers MACs and algorithms.
if [ ! $(egrep -c "$_ciphers|$_macs|$_KEYalgorithms" $_logdir/$_host.client_KEXINIT) -eq 0 ]; then
    echo "Your Local_HOST $(hostname) is offering outdated/unsupported ciphers, macs and KEYalgorithms."
        else
        echo "Your Local_HOST $(hostname) is not offering unsupported ciphers, macs and KEYalgorithms"
fi
