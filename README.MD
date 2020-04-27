[Jekyll](https://jekyllrb.com/) is a blog-aware static site generator.

In this repository, I run `jekyll build` and build the blog part of my website. 

The website is hosted on a [balena](https://balena.io) powered Raspberry pi 4, thus when I build the blog, I push to github and then connect to the server (Rpi4) to fetch the new version. I have automated the whole process with a script named `deploy.sh`

The website is served by nginx, thus I only need to update the source files and nginx will serve them automatically.

The actual website's source files are hosted on [odyslam.github.io Repository](https://github.com/OdysLam/odyslam.github.io) 

The website used to be hosted on Github Pages, thus the Repository's name.
