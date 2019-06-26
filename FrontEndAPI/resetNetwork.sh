docker stop -f $(docker ps -aq)
docker rm -f $(docker ps -aq)
docker rmi $(docker images -q)
docker network prune
