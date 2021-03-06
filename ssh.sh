#!/bin/bash

source database.conf

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
# user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; select * from bash.admins;") >/dev/null 2>&1

#authentication with api
denied=true
while $denied; do
    clear
    toilet --filter metal 'SSH-Manager'

    tput setaf 3;
    echo 'Welcome to Terminal-SSH-Manager'
    tput setaf 2;
    echo 'Version:"1.0"'
    echo 'Authored by : "Behzad Fazelasl"'
    tput setaf 7;

    open='{"username":"'
    echo "username :"
    read username
    middle='","password":"'
    echo "password:"
    read password
    close='"}'

    result=$(curl --location --request POST 'http://tsm.kiantc.com/auth/login' --header 'Content-Type: application/json' --data-raw $open$username$middle$password$close);
    if [ $result = true ]
    then
        denied=false
    else
        echo "Access denied!"
        echo "Try again.."
        sleep 2
    fi
done

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
    
    echo "press [0] to config | press [1] to see the LIST"
    echo "press [2] to add new host | press [3] to manage existing"
    read status
    if [ '1' = $status ] >/dev/null 2>&1
        then
    
        mysql --host=$hostname --user=$db_username --password=$db_password --batch --silent --skip-column-names --execute="use $db_name; select id , username from bash.hosts;" | while read id username; do
            echo "$(echo $id - $username | toilet -f term -F border --gay)";
        done 
        
        echo "Enter chosen host's ID :"
        read id
        username=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select username from bash.hosts where id='$id';") >/dev/null 2>&1
        password=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select password from bash.hosts where id='$id';") >/dev/null 2>&1
        ip=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select ip from bash.hosts where id='$id';") >/dev/null 2>&1
        port=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select port from bash.hosts where id='$id';") >/dev/null 2>&1
        
        sshpassp="sshpass -p '"
        ssh="' ssh "

        excutiveCommand="$sshpassp$password$ssh$username@$ip -p $port"

        #  gnome-terminal -e "$excutiveCommand" #depricated
        gnome-terminal -- /bin/bash -c "$excutiveCommand;"

    elif [ '0' = $status ] >/dev/null 2>&1
        then
        gnome-terminal -- /bin/bash -c "nano database.conf"
        PID=$!
        kill -9 $PID
    elif [ '3' = $status ] >/dev/null 2>&1  #delete hosts
        then
        mysql --host=$hostname --user=$db_username --password=$db_password --batch --silent --skip-column-names --execute="use $db_name; select id , username from bash.hosts;" | while read id username; do
            echo "$(echo $id - $username | toilet -f term -F border --gay)";
        done 
        
        echo "Enter chosen host's ID :"
        read id

        username=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select username from bash.hosts where id='$id';") >/dev/null 2>&1
        password=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select password from bash.hosts where id='$id';") >/dev/null 2>&1
        ip=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select ip from bash.hosts where id='$id';") >/dev/null 2>&1
        port=$(mysql --host=localhost --user=behzad --password=dollar --batch --silent --execute="use bash; select port from bash.hosts where id='$id';") >/dev/null 2>&1
        
        echo "press [0] to delete | press [1] to edit"
        read action
        if [ '0' = $action ] >/dev/null 2>&1
            then
            mysql -h localhost -ubehzad -pdollar -B -e "use bash; delete from hosts where id=$id;"
        else
            echo "enter new credentials, leave it blank if you don't want it to change"

            echo "new username :"
            read new_username
            if [ -n "$new_username" ] 
                then
                mysql -h localhost -ubehzad -pdollar -B -e "use bash; update bash.hosts set username='$new_username' where id=$id;"   
            fi

            echo "new password :"
            read new_password
            if [ -n "$new_password" ] 
                then
                mysql -h localhost -ubehzad -pdollar -B -e "use bash; update bash.hosts set password='$new_password' where id=$id;"   
            fi

            echo "new ip :"
            read new_ip
            if [ -n "$new_ip" ] 
                then
                mysql -h localhost -ubehzad -pdollar -B -e "use bash; update bash.hosts set ip='$new_ip' where id=$id;"   
            fi

            echo "new port :"
            read new_port
            if [ -n "$new_port" ] 
                then
                mysql -h localhost -ubehzad -pdollar -B -e "use bash; update bash.hosts set port='$new_port' where id=$id;"   
            fi

        fi
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