
if ! dpkg --get-selections | grep -q "^figlet[[:space:]]*install$" >/dev/null; then
    sudo apt install figlet
fi

if ! dpkg --get-selections | grep -q "^toilet[[:space:]]*install$" >/dev/null; then
    sudo apt install toilet
fi

toilet --filter metal 'SSH-Manager'

tput setaf 3;
echo 'Welcome to Terminal-SSH-Manager'
tput setaf 2;
echo 'Version:"1.0"'
echo 'Authored by : "Behzad Fazelasl"'
tput setaf 7;
user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; select * from bash.admins;") >/dev/null 2>&1
if [ -z" $user"] >/dev/null 2>&1 # means we have no admin in the database
    then
    echo "please enter a username"
    read username
    echo "please enter your password"
    read password
    user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; insert into admins ( username, password ) VALUES ('$username', '$password');") >/dev/null 2>&1

else
    echo "username :"
    read username
    echo "password:"
    read password

    user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; select * from admins where username='$username' AND password='$password';") >/dev/null 2>&1

    if [ -z "$user"] >/dev/null 2>&1 # means we have no admin in the database
    then
        echo "username or password wrong!"
    else
        over=true
        while $over; do
            clear
            toilet --filter metal 'SSH-Manager'

            tput setaf 3;
            echo 'Welcome to Terminal-SSH-Manager'
            tput setaf 2;
            echo 'Version:"1.0"'
            echo 'Authored by : "Behzad Fazelasl"'
            tput setaf 7;
            
            echo "press [1] to see the LIST | press [2] to add new host"
            read status
            if [ '1' = $status ] >/dev/null 2>&1
                then
            
                mysql -h localhost -ubehzad -pdollar -B -s -N -e "use bash; select id , username from bash.hosts;" | while read id username; do
                    echo "$(echo $id - $username | toilet -f term -F border --gay)";
                done 
                
                echo "Enter chosen host's ID :"
                read id
                username=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select username from bash.hosts where id='$id';") >/dev/null 2>&1
                password=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select password from bash.hosts where id='$id';") >/dev/null 2>&1
                ip=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select ip from bash.hosts where id='$id';") >/dev/null 2>&1
                port=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select port from bash.hosts where id='$id';") >/dev/null 2>&1
                
                sshpassp="sshpass -p '"
                ssh="' ssh "

                excutiveCommand="$sshpassp$password$ssh$username@$ip -p $port"

                #  gnome-terminal -e "$excutiveCommand" #depricated
                gnome-terminal -- /bin/bash -c "$excutiveCommand;"

            
            else
                echo "you have a new host to add,please enter credentials"
                echo "username :"
                read username
                echo "password :"
                read password
                echo "ip :"
                read ip
                echo "port :"
                read port

                user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; insert into hosts ( username, password,ip ,port ) VALUES ('$username', '$password','$ip','$port');") >/dev/null 2>&1

            fi

            echo "want to exit ? [Y/N]"
            read ex

            if [ $ex = 'Y' ]
            then
                over=false
                tput setaf 5;
                echo "Thank you for using Terminal-SSH-Manager!"
                echo "Bye !!"
            fi

        done
    fi
fi

