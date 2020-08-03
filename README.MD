[Jekyll](https://jekyllrb.com/) is a blog-aware static site generator.

This repository holds the source files for my [blog](https://odyslam/blog). To build the blog, I run `bundle exec jekyll build` which takes care of all the dependencies and outputs a website in plain `html`, `js` and `css`.

The website is hosted on a [balena](https://balena.io) powered Raspberry pi 4, thus when I build the blog, I push to github and then connect to the server (Rpi4) to fetch the new version. 

I have automated the whole process with a script named `deploy.sh` (and `deploy-local.sh`).

The website is served by nginx, thus I only need to update the source files and nginx will serve them automatically.

The actual website's source files are hosted on [odyslam.github.io Repository](https://github.com/OdysLam/odyslam.github.io) 
