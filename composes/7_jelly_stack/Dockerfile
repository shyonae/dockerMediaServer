FROM lscr.io/linuxserver/jellyfin:latest

RUN apt update && apt install -y openssh-client python3-click python3-yaml wget && wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg -O /usr/local/bin/rffmpeg && chmod +x /usr/local/bin/rffmpeg && ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffmpeg && ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffprobe && mkdir -p /etc/rffmpeg && apt purge wget -y && rm -rf /var/lib/apt/lists/* && apt autoremove --purge -y && apt clean

ENTRYPOINT "./jellyfin/jellyfin"
