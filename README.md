# Dockerized Your Symfony Project
##### Docker + Compose :: Symfony + PHP 5.6 + MySQL + Doctrine Migrations on Debian
This repository will provide the simple tools you need to spin up a quick and disposable development instance of your Symfony project.  The docker instance produced by this setup is not intended for production use.  It is as light weight as I could make it, meaning that it uses PHP's internal server, which is not production friendly.  

### A Use Case
If your Symfony application is running on PHP 5.4, but you want to upgrade to PHP 5.6, this project will allow you to do that without worrying about standing up a new server or VM with 5.6, or dealing with the headache of installing 5.6 alongside 5.4 on your dev machine, which can be trickier than it sounds in some environments. You can then sort out and resolve your 5.4 deprication issues by testing against your docker instance, which will ultimately allow you to update the PHP on your dev/staging/prod servers in rapid succession with confidence and minimal headache.  Likewise, you could adjust the ```symfony/Dockerfile``` file to install PHP 7 and its associated libraries to test your code in a similar fashion. You could even have multiple instances of the repository that use different versions of PHP/MySQL and test any of your changes against all docker containers to ensure that they will run on multiple versions without issue.  If you are into continuous integration, you could use this project as a foundation to spin up multiple environments running different PHP/MySQL version and run unit tests in all of them before allowing a pull request to be merged, to ensure cross platform compatability.

### An Ass Out Of You and Me
If you want to use this project out of the box, you should caters to the following assumtions.  If some of these do not apply to you, adjusting this code to work with your setup could be very simple, depending on your setup.  You can probably figure it out, but if you can't, remember that G**gle is your friend:

1. ```database_user:``` is set to ```root``` in your application's ```parameter.yml``` file
1. ```database_host:``` is set to ```localhost``` in your application's ```parameters.yml``` file
1. your Symfony application appeals to a single MySQL database
1. you have a fully installed copy of your application on your host mahcine; ```composer install``` must have already been run, so no skeleton git/svn repo code.  This shouldn't be a problem if you're running the docker instance on your real dev machine, which I'd recommend as the easiest approach.
1. you have a ```mysqldump``` file of your database on your local machine
1. you do not have any server dependencies outside of those explicitly stated in the ```apt-get``` clause in ```symfony/Dockerfile```. If you do have additional dependencies, just add them!

### Setup
1. install [Docker Engine](https://docs.docker.com/engine/installation/)
1. install [Docker Compose](https://docs.docker.com/compose/install/)
1. add your user to the docker group (see documentation above), otherwise prepend ```sudo``` to all docker/docker-compose commands below
1. ```git clone git@github.com:arderyp/dockerize-symfony.git```
1. ```cd dockerize-symfony```
1. edit the ```LOCALHOST_CODE_SOURCE_DIR``` and ```LOCALHOST_DATABASE_DUMP_FILE``` variables in ```prepare.sh``` to point to local copies of your Symfony project root and database dump file respectively (see assumptions above)
1. replace ```YOUR_ROOT_PASSWORD``` and ```YOUR_DATABASE``` with your respective root password and database name in ```docker-compose.yml```
1. ```sudo ./prepare.sh```
1. ```docker-compose up -d```
 

### Helpful Commands
Docker and docker-compose offer many useful options, and both projects appear to be evolving at a steady pace, so please see the most current versions of their respective documentation for the most up-to-date features.

    # Shut down your docker instance
    docker-compose down
------
    # List all of your docker processes
    docker ps -a
------
    # Get shell access to your running MySQL or Symfony container (get <container id> from command above)
    docker exec -it <container id> bash
------
    # Connect to your container's mysql instance from your host machine (your MySQL container must be running)
    mysql -u root -p -h 0.0.0.0 -P 3307
------
    # Stop and remove all running containers
    docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
------
    # Blow away everything to rebuild and run from scratch
    docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images | awk {'print $3'}); sudo ./prepare.sh && docker-compose up -d
