jekyll build -d /Users/odys/Github/odyslam.github.io
cd /Users/odys/Github/odyslam.github.io/
git commit --signoff -m "$1"
git push
echo "new post pushed to github!"
balena login --token eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjUzMDgsInVzZXJuYW1lIjoiZ2hfb2R5c2xhbSIsImVtYWlsIjoib2R5c3NlYXMwMDdAd2luZG93c2xpdmUuY29tIiwiY3JlYXRlZF9hdCI6IjIwMTctMDktMjNUMTA6MDY6MTIuMDI3WiIsImp3dF9zZWNyZXQiOiJZVERSUlI0WlpDQjZWQ01SSUFRWUhVMzJGUE5IWVhPVSIsImhhc19kaXNhYmxlZF9uZXdzbGV0dGVyIjpmYWxzZSwiZmlyc3RfbmFtZSI6Im9keXNzZWFzICIsImxhc3RfbmFtZSI6ImxhbXR6aWRpcyIsImFjY291bnRfdHlwZSI6InBlcnNvbmFsIiwic29jaWFsX3NlcnZpY2VfYWNjb3VudCI6W3sicHJvdmlkZXIiOiJnaXRodWIiLCJkaXNwbGF5X25hbWUiOiJPZHlzTGFtIn1dLCJjb21wYW55Ijoic3R1ZGVudCIsImhhc1Bhc3N3b3JkU2V0IjpmYWxzZSwibmVlZHNQYXNzd29yZFJlc2V0IjpmYWxzZSwicHVibGljX2tleSI6dHJ1ZSwiZmVhdHVyZXMiOltdLCJpbnRlcmNvbVVzZXJOYW1lIjoiZ2hfb2R5c2xhbSIsImludGVyY29tVXNlckhhc2giOiIzNWQ0NTE4OWMwYjVkZWEzMmMyYWY2MTkzM2ZmMGFjNGI5NGU0ZmYyYjM2NTg5N2JhNWQ3MjA5MjVlODIxMmFkIiwicGVybWlzc2lvbnMiOltdLCJhdXRoVGltZSI6MTU4NDc5Njg0MjAwNiwiYWN0b3IiOjE3ODM3NDgsImlhdCI6MTU4NTQ5MzMwOSwiZXhwIjoxNTg2MDk4MTA5fQ.161yOShkHA791pHtnOiGktd03HThms56wKO5gcd6D6E
balena ssh b6811f2.local nginx

# ssh -p 22222 root@192.168.1.110 <<'ENDSSH'
# CONTAINER_ID="$(balena-engine ps | grep 'nginx' | awk '{print $1;}')"
# balena-engine exec -it $a /bin/sh 
# cd /tmp/
wget https://github.com/OdysLam/odyslam.github.io/archive/master.zip
unzip -q master.zip && rm master.zip
cp /tmp/odyslam.github.io-master/blog/* /usr/share/nginx/html/blog/
rm -rf /tmp/odyslam.github.io-master/
# exit
# ENDSSH
