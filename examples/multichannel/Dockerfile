FROM hyperledger/fabric-baseimage:x86_64-0.2.2
WORKDIR /opt/gopath/src/github.com/hyperledger/fabric/examples/multichannel
COPY /ccenv /opt/gopath/src/github.com/hyperledger/fabric/examples/multichannel/ccenv
COPY /ccenv/Dockerfile.in /opt/gopath/src/github.com/hyperledger/fabric/examples/multichannel/ccenv/Dockerfile.in
RUN touch /opt/gopath/src/github.com/hyperledger/fabric/examples/multichannel/ccenv/Dockerfile
COPY docker-compose-channel.yml /opt/gopath/src/github.com/hyperledger/fabric/examples/multichannel/
COPY setenv.sh /opt/gopath/src/github.com/hyperledger/fabric/examples/multichannel/setenv.sh
RUN chmod 755 /opt/gopath/src/github.com/hyperledger/fabric/examples/multichannel/setenv.sh

