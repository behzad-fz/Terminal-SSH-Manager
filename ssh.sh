read serverName

if [ 'sky' = $serverName ]
then
sshpass -p '5clUW4gf' ssh skywriters@144.76.143.167 -p 49150
else
echo "no such server exists in our database!"
fi
