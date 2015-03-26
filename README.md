
# 构造image
$ docker build -t hqingyi/docker_emailserver --rm ./docker_emailserver
# 初始化
$ docker run --name emailserver -p 25:25 -p 465:465 -p 587:587 -p 993:993 -p 995:995 -p 13306:3306 -d -it hqingyi/docker_emailserver /bin/bash
