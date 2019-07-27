docker stop -f $(docker ps -aq)
echo y | docker rm -f $(docker ps -aq)
echo y | docker rmi $(docker images -q)
echo y | docker network prune
