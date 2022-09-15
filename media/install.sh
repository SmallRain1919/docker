#!/bin/bash
#
#


media(){
mkdir -p /data/{media/{tv,movies,comics},downloads/{tv,movies,comics},docker/{nastools/config,jellyfin/config,qbittorrent/config,jackett/config}
}

nastools(){

docker run -d \
    --name nas-tools \
    --hostname nas-tools \
    -p 3000:3000  \
    -v /data/docker/nastools/config:/config \
    -v /data/media:/media  \
    -e PUID=0           \
    -e PGID=0           \
    -e UMASK=000    \
    -e NASTOOL_AUTO_UPDATE=false  \
    jxxghp/nas-tools

}


jellyfin(){

docker run -d \
  --name=jellyfin \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e JELLYFIN_PublishedServerUrl=192.168.1.200 \
  -p 8096:8096 \
  -p 8920:8920  \
  -p 7359:7359/udp  \
  -p 1900:1900/udp  \
  -v /data/docker/jellyfin/config:/config \
  -v /data/media/movies:/data/movies \
  -v /data/media/tv:/data/tv \
  -v /data/media/comics:/data/comics \
  --restart unless-stopped \
  lscr.io/linuxserver/jellyfin:latest

}

qbittorrent(){

docker run -d \
  --name=qbittorrent \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e WEBUI_PORT=8080 \
  -p 8080:8080 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v /data/docker/qbittorrent/config:/config \
  -v /data/downloads:/downloads \
  --restart unless-stopped \
  lscr.io/linuxserver/qbittorrent:latest

}

jackett(){

docker run -d \
  --name=jackett \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai  \
  -e AUTO_UPDATE=true  \
  -p 9117:9117 \
  -v /data/docker/jackett/config:/config \
  -v /data/downloads:/downloads \
  --restart unless-stopped \
  lscr.io/linuxserver/jackett:latest

}

start(){
media
nastools
jellyfin
jackett
qbittorrent
docker_uinstall
docker_media
}

docker_rm(){

docker stop jellyfin
docker rm jellyfin
docker rmi jellyfin

docker stop jackett
docker rm jackett
docker rmi jackett

docker stop qbittorrent
docker rm qbittorrent
docker rmi qbittorrent

docker stop nas-tools
docker rm nas-tools
docker rmi nas-tools

}



read -p "请确认是否安装：[Y|N]"  pass

case $pass in
        Y|y)

                echo "正在安装。。。"
                start
				
				
        ;;

        N|n)
                echo "正在取消。。。"
               
				
        ;;
        *)
esac


docker_media(){
echo -e '#!/bin/bash
#
#
docker_start(){

docker start jackett 		        | echo -e "[\033[32m jackett   		启动成功......\033[0m]\n"

docker start nas-tools          	| echo -e "[\033[32m nas-tools  	 	启动成功......\033[0m]\n"

docker start qbittorrent       		| echo -e "[\033[32m qbittorrent       	启动成功......\033[0m]\n"

docker start jellyfin           	| echo -e "[\033[32m jellyfin           	启动成功......\033[0m]\n"

}

docker_stop(){


docker stop jackett  			| echo -e "[\033[32m jackett		停止成功......\033[0m]\n"

docker stop nas-tools     	  	| echo -e "[\033[32m nas-tools		停止成功......\033[0m]\n"

docker stop qbittorrent			| echo -e "[\033[32m qbittorrent		停止成功......\033[0m]\n"

docker stop jellyfin			| echo -e "[\033[32m jellyfin 		停止成功......\033[0m]\n"

}

docker_restart(){

docker restart jackett			| echo -e "[\033[32m jackett		重启成功......\033[0m]\n"

docker restart nas-tools		| echo -e "[\033[32m nas-tools		重启成功......\033[0m]\n"

docker restart qbittorrent		| echo -e "[\033[32m qbittorrent		重启成功......\033[0m]\n"

docker restart jellyfin			| echo -e "[\033[32m jellyfin		重启成功......\033[0m]\n"

}


case $1 in
        start)
                echo "正在启动媒体服务器......"
                docker_start 
        ;;

        stop)
                echo "正在停止媒体服务器......"
                docker_stop 
        ;;

        restart)
                echo "正在重启媒体服务器......"
                docker_restart 
        ;;

        *)

esac



' >> docker_media && chmod 777 docker_media
}


docker_uinstall(){

echo "#!/bin/bash
docker_rm(){

docker stop jellyfin
docker rm jellyfin
docker rmi jellyfin

docker stop jackett
docker rm jackett
docker rmi jackett

docker stop qbittorrent
docker rm qbittorrent
docker rmi qbittorrent

docker stop nas-tools
docker rm nas-tools
docker rmi nas-tools

rm -rf /data/do*
rm -rf uinstall.sh
}

" >> uinstall

chmod 777 uinstall

}