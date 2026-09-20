# forky (debian testing as for 17 sept 2026) 
# FROM docker.io/library/debian@sha256:7897a178ffc0a87381b34e6cc58379e01032d2ea0651c37e59db04cce150c43b 
FROM docker.io/library/debian:forky

USER root
ENV LANG=C.UTF-8
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends adduser build-essential \
      gcc-multilib g++-multilib flex bison gperf bc rsync schedtool \
      gnupg curl ca-certificates zip unzip xz-utils bzip2 \
      diffutils openssl libssl-dev libxml2-utils xsltproc squashfs-tools \
      libncurses-dev zlib1g-dev libfreetype-dev fontconfig fonts-dejavu \
      libswitch-perl vim xxd hostname python3 python-is-python3 git git-lfs \
      tree nano less procps pkgconf patch ccache nodejs npm libsdl1.2-dev \
      openssh-client systemd-standalone-sysusers systemd-standalone-tmpfiles \
      libc6-i386 lib32stdc++6 lib32z1 lib32tinfo6 lib32ncurses6 lib32readline8 libegl1 \
      libasound2t64 libx11-6 libxext6 libxi6 libxrender1 libxtst6 libxrandr2 libgl1 \
      libc6-dev-i386 lib32gcc-s1 android-tools-adb mesa-vulkan-drivers libgl1-mesa-dri \
      libxkbfile1 libnss3 libnspr4 libgtk-3-0 libxcursor1 libxcomposite1 libxdamage1 \
      qemu-kvm libglib2.0-0 libegl-mesa0 dbus-x11 xdg-utils && \
    printf '#!/bin/sh\ncommand -v "$@"\n' > /usr/local/bin/which && \
    chmod 0755 /usr/local/bin/which && \
    test -e /usr/lib/ld-linux.so.2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo && \
    echo '1211b57b57e4122a9c546295a59b37d24068f1164d0e87bef096d5323c413e4f /usr/local/bin/repo' | sha256sum -c - && \
    chmod 0755 /usr/local/bin/repo

RUN curl -fsSL -o /tmp/asfp.deb 'https://dl.google.com/android/asfp/asfp-Panda%202-2025.3.2.6-linux.deb' && \
    echo '98024f9834a813d4933a1e39bb47487a32f84f247c088a9c18c8628b12052167 /tmp/asfp.deb' | sha256sum -c - && \
    dpkg-deb -x /tmp/asfp.deb /tmp/asfp-extract && \
    mv /tmp/asfp-extract/tmp/android-studio-for-platform-Stable.2.6 /opt/android-studio-for-platform && \
    rm -rf /tmp/asfp.deb /tmp/asfp-extract && \
    ln -s /opt/android-studio-for-platform/bin/studio /usr/local/bin/android-studio-for-platform && \
    ln -s /opt/android-studio-for-platform/bin/studio /usr/local/bin/asfp && \
    test -x /usr/local/bin/android-studio-for-platform && \
    test -x /opt/android-studio-for-platform/bin/studio

RUN npm install --global yarn@1.22.22 && \
    rm -rf /root/.npm && \
    yarn --version

RUN rm -f /usr/bin/sudo /usr/bin/sudo_log && \
    [ ! -e /usr/bin/sudo ] || { echo "sudo removal check failed" >&2; exit 1; } && \
    find / -xdev \( -perm /4000 -o -perm /2000 \) -print0 | xargs -0 -r chmod u-s,g-s && \
    if [ -n "$(find / -xdev \( -perm /4000 -o -perm /2000 \) -print)" ]; then echo "suid sweep check failed" >&2; exit 1; fi && \
    useradd -m -s /bin/bash aosp-dev && mkdir -p /home/aosp-dev/.container-runtime && \
    chown aosp-dev:aosp-dev /home/aosp-dev/.container-runtime && chmod 700 /home/aosp-dev/.container-runtime

USER aosp-dev
ENV HOME=/home/aosp-dev
WORKDIR /home/aosp-dev
RUN git config --global color.ui false && \
    git config --global user.email "stub@stub" && \
    git config --global user.name "stub"

USER aosp-dev
CMD ["bash"]
