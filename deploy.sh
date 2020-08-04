# This script is used to build the jekyll blog part of the website and update the git repository
# It then logs me into balena (the webserver) in order to run manually another script which downloads the updated website to the server.


export J_OUTPUT=/Users/odys/Github/odyslam.github.io/blog/
export REPO=/Users/odys/Github/odyslam.github.io
export CLYELL=/Users/odys/Github/clyell
export DEV_UUID=b6811f2
if [ -z "$1" ]; then 
    github=0
elif [ $1 = 'push' ]; then
    echo "pushing chnanges to remote repository"
    git push 
    github=1
elif [ $1 = 'commit' ]; then
    echo "commiting and pushing changes to remote repository"
    git add -A && git commit --signoff -m "$2"
    git push
    github=1
else 
    echo "Unknown command, aborting"
    exit 1
fi
if [ $? -eq 0 ]; then
    continue
else 
    echo "failed to push changes to clyell repository"
    exit 1
fi
if [ $github -eq 1 ]; then
    bundle exec jekyll build -d $J_OUTPUT
    if [ $? -eq 0 ]; then
        cd $REPO
        git add -A && git commit --signoff -m "$2" 
        if [ $? -eq 0 ]; then
            git push && echo "Changes were pushed to Github!"
        else
            echo "no commit message, deploy is aborted.."    
            exit 1
        fi
    else
        echo "Jekyll build failed, please try again"
        exit 1
    fi
fi
cd $CLYELL
echo "Reading balena token from file.."
if [[ $(cat ./balena_token) ]]; then
    token=$(cat ./balena_token)
    balena login -t $token
    balena tunnel b6811f2 -p 22222:1234 &
    echo "Sleeping for 6s to allow the tunnel to be established"
    sleep 6
    CONTAINER_ID=$(ssh -Tp 1234 root@127.0.0.1 <<< 'balena-engine ps' | grep 'nginx' | awk '{print $1}')
    ssh -Tp 1234 root@127.0.0.1 "balena-engine exec $CONTAINER_ID /bin/sh /update-blog.sh"
    echo "deployment to webserver was succesful"
else
    echo "Could not read balena_token file, aborting deployment to webserver"
fi


# export BALENA_TOKEN=$(cat balena_token) 
# balena login --token $BALENA_TOKEN
# balena ssh b6811f2 nginx

# ssh -p 22222 root@192.168.1.110 <<'ENDSSH'
# CONTAINER_ID="$(balena-engine ps | grep 'nginx' | awk '{print $1;}')"
# balena-engine exec -it $a /bin/sh 
# cd /tmp/

# /update_blog.sh script
# cd /tmp/
# wget https://github.com/OdysLam/odyslam.github.io/archive/master.zip
# unzip -q master.zip 
# rm master.zip
# cp /tmp/odyslam.github.io-master/blog/* /usr/share/nginx/html/blog/
# rm -rf /tmp/odyslam.github.io-master
# echo "blog updated & removed any leftover files"