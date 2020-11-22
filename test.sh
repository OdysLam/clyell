export CLYELL=/Users/odys/Github/clyell

function get_devrel_resources() {
    rm -rf $CLYELL/devrel-resources-main
    wget https://github.com/OdysLam/devrel-resources/archive/main.zip -O $CLYELL/main.zip
    unzip -q $CLYELL/main.zip
    rm $CLYELL/main.zip
    cat > $CLYELL/devrel-resources-main/index.md <<- EOM
---
layout: post
title:	"Developer Relations Resources"
author: "Odysseas Lamtzidis"
tags:
    - "developer relations"
    - "2020"
excerpt: "Curated list of Resources for Developer Relations"
vertical: developer-relations
---
EOM
cat $CLYELL/devrel-resources-main/README.md >> $CLYELL/devrel-resources-main/index.md

cat > $CLYELL/devrel-resources-main/discourse-guide.md <<- EOM
---
layout: post
title:	"Discourse Guide"
author: "Odysseas Lamtzidis"
tags:
    - "developer relations"
    - "2020"
    - "Discourse"
    - "Community Management"
excerpt: "An all encompasing one-stop guide to launch a succesful Discourse forum"
vertical: developer-relations
---
EOM
cat $CLYELL/devrel-resources-main/discourse.md >> $CLYELL/devrel-resources-main/discourse-guide.md
rm $CLYELL/devrel-resources-main/discourse.md && rm $CLYELL/devrel-resources-main/README.md

}

get_devrel_resources