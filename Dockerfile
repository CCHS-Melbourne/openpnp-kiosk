FROM alwaysai/edgeiq-dev:nano-latest

ENV DEBIAN_FRONTEND noninteractive
# Mouse/keyboard support
ENV UDEV=1

# Install desktop environment...
RUN apt-get update
RUN apt-get install -qq -y wget curl git \
					 xserver-xorg-core xserver-xorg-input-all xinit xauth dbus-x11 usbutils \
					 icewm

# ...and required openpnp deps
RUN apt-get install -qq -y maven ant \
                     libjna-jni libtiff5 libpng16-16 libpng-sixlegs-java libatlas3-base \
                     libgstreamer1.0-0 libgstreamer-plugins-base1.0-dev libgstreamer-gl1.0-0 \
                     libgstreamer-plugins-bad1.0-0 \
                     libv4l-0 libxvidcore4

RUN echo "#!/bin/bash" > /etc/X11/xinit/xserverrc \
  && echo "" >> /etc/X11/xinit/xserverrc \
  && echo 'exec /usr/bin/X -s 0 dpms -nolisten tcp "$@"' >> /etc/X11/xinit/xserverrc

# Setting working directory
WORKDIR /usr/src/app

# Download OpenPnP
RUN wget https://s3-us-west-2.amazonaws.com/openpnp/OpenPnP-linux-test.deb

# Download Corretto, since OpenJDK seems to be only available as JRE in Debian bullseye for ARM64
RUN wget https://corretto.aws/downloads/latest/amazon-corretto-11-aarch64-linux-jdk.deb
ENV JAVA_HOME /usr/lib/jvm/java-11-amazon-corretto

# Install Java and OpenPnP
RUN dpkg -i *.deb && rm *.deb

# Provision OpenPNP configuration, to be refined with more accessible remote provisioning
RUN mkdir -p /root/.openpnp2 /root/.config
COPY config/machine.xml /root/.openpnp2/machine.xml
## Those cannot be empty, otherwise OpenPnP crashes
#COPY config/parts.xml /root/.openpnp2/parts.xml
#COPY config/packages.xml /root/.openpnp2/packages.xml

# Prepare to start the kiosk
COPY start.sh start.sh
RUN chmod -x start.sh

CMD ["bash", "start.sh"]
