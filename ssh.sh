read serverName

if [ 'sky' = $serverName ]
then
sshpass -p '*******' ssh skywriters@144.76.143.167 -p *****
else
echo "no such server exists in our database!"
fi
