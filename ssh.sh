

echo "Welcome to Terminal-SSH-Manager"

user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; select * from bash.admins;")
if [ -z "$user"] # means we have no admin in the database
    then
    echo "please enter a username"
    read username
    echo "please enter your password"
    read password
    user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; insert into admins ( username, password ) VALUES ('$username', '$password');")

else

    echo "you want to login ? enter your credentials"
    echo "username :"
    read username
    echo "password:"
    read password

    user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; select * from admins where username='$username' AND password='$password';")

    if [ -z "$user"] # means we have no admin in the database
    then
        echo "username or password wrong"
    else
        
        echo "if you wanna connect to a host, press [1] | if you wanna add new host, press [2]"
        read status
        if [ '1' = $status ] 
            then
            echo "which server are you intending to connect ? plz enter the id"
            servers=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; select * from bash.hosts;")
            echo $servers
            read id
            username=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select username from bash.hosts where id='$id';")
            password=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select password from bash.hosts where id='$id';")
            ip=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select ip from bash.hosts where id='$id';")
            port=$(mysql -h localhost -ubehzad -pdollar -B -se "use bash; select port from bash.hosts where id='$id';")
            
            sshpass -p "$password" ssh $username@$ip -p $port
            #  sshpass -p '5clUW4gf' ssh skywriters@144.76.143.167 -p 49150

        
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

            user=$(mysql -h localhost -ubehzad -pdollar -B -e "use bash; insert into hosts ( username, password,ip ,port ) VALUES ('$username', '$password','$ip','$port');")

        fi
    fi
fi
