FROM alpine:3.13 

RUN apk add --no-cache build-base~=0.5 pcre2-dev~=10.36 git~=2.30.3 cmake~=3.18.4 libssh-dev~=0.9.5 openssl-dev~=1.1.1 openssl~=1.1.1 bash~=5.1.16

ARG LIBYANG_VERSION
ARG SYSREPO_VERSION
ARG LIBNETCONF2_VERSION
ARG NETOPEER2_VERSION

RUN echo "/lib:/usr/local/lib:/usr/lib:/usr/local/lib64" > /etc/ld-musl-x86_64.path

#Build libyang
WORKDIR /
RUN git clone https://github.com/CESNET/libyang.git
WORKDIR /libyang
RUN git checkout $LIBYANG_VERSION && mkdir build
WORKDIR /libyang/build
RUN cmake -D CMAKE_BUILD_TYPE:String="Release" .. && \
    make && \
    make install

#Build sysrepo
WORKDIR /
RUN git clone https://github.com/sysrepo/sysrepo.git
WORKDIR /sysrepo
RUN git checkout $SYSREPO_VERSION && mkdir build
WORKDIR /sysrepo/build
RUN cmake -D CMAKE_BUILD_TYPE:String="Release" .. && \
    make && \
    make install

#Build libnetconf2
WORKDIR /
RUN git clone https://github.com/CESNET/libnetconf2.git
WORKDIR /libnetconf2
RUN git checkout $LIBNETCONF2_VERSION && mkdir build
WORKDIR /libnetconf2/build
RUN cmake -D CMAKE_BUILD_TYPE:String="Release" .. && \
    make && \
    make install

#Build netopeer2
WORKDIR /
RUN git clone https://github.com/CESNET/netopeer2.git
WORKDIR /netopeer2
RUN git checkout $NETOPEER2_VERSION && mkdir build
WORKDIR /netopeer2/build
RUN cmake -D CMAKE_BUILD_TYPE:String="Release" .. && \
    make && \
    make install

# Import the yang modules in sysrepo
COPY ./yang-files /yang
RUN for f in /yang/*.yang; do sysrepoctl -i "$f" -s /yang -p 664 -v3; done

COPY ./conf-files /conf
# Populate the yang library in external schema mount data
RUN sysrepocfg -X -x/ietf-yang-library:* -d operational >> /conf/schema-mount.xml
# Disable nacm to test edit-config easily
RUN sysrepocfg --import=/conf/nacm.xml -d startup -m ietf-netconf-acm
RUN sysrepocfg --import=/conf/nacm.xml -d running -m ietf-netconf-acm
RUN sysrepocfg --import=/conf/nacm.xml -d candidate -m ietf-netconf-acm

# Create a user to log with netopeer2-cli
ARG NETCONF_USER=user
ARG NETCONF_PASSWORD=pass

RUN addgroup -S netconf
RUN adduser $NETCONF_USER --uid 1001 -G netconf --disabled-password
RUN echo $NETCONF_USER:$NETCONF_PASSWORD | chpasswd

WORKDIR /

# The startup script runs netopeer2-server with schema mount data
# before netopeer2-cli
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD /bin/ash /startup.sh