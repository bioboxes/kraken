FROM ubuntu:latest
MAINTAINER Peter Belmann pbelmann@cebitec.uni-bielefeld.de

ENV INSTALL_DIR /usr/local/bin/

RUN apt-get update
RUN apt-get install -y jq wget make g++

# Locations for biobox validator
ENV BASE_URL  https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION   0.x.y
ENV VALIDATOR /bbx/validator/
RUN sudo mkdir -p  ${VALIDATOR} && sudo chmod -R a+wx  /bbx

# install yaml2json and jq tools
ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
RUN cd /usr/local/bin &&  wget --quiet ${CONVERT} && sudo chmod a+x /usr/local/bin/yaml2json

RUN wget --output-document - http://www.cbcb.umd.edu/software/jellyfish/jellyfish-1.1.11.tar.gz \
           | tar xzf - --directory $INSTALL_DIR  --strip-components=1

RUN cd $INSTALL_DIR && ./configure --prefix=/usr/local/bin && make && make  install 
ENV PATH ${INSTALL_DIR}bin:$PATH

RUN wget --output-document - https://github.com/DerrickWood/kraken/archive/v0.10.5-beta.tar.gz \
           | tar xzf - --directory $INSTALL_DIR  --strip-components=1

RUN mkdir -p /bbx/output
ADD install_kraken.sh $INSTALL_DIR
ADD run.sh /usr/local/bin/
ADD tasks /
RUN cd /usr/local/bin && sudo /bin/bash install_kraken.sh /usr/local/bin

ENTRYPOINT ["/usr/local/bin/run.sh"]
