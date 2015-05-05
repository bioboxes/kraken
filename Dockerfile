FROM ubuntu:latest
MAINTAINER Peter Belmann pbelmann@cebitec.uni-bielefeld.de

ENV INSTALL_DIR /usr/local/bin/

RUN apt-get update
RUN apt-get install -y xz-utils ca-certificates jq wget make g++

# Locations for biobox validator
ENV BASE_URL  https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION   0.x.y
ENV VALIDATOR /bbx/validator/
RUN mkdir -p  ${VALIDATOR}
ADD schema.yaml ${VALIDATOR}

# install yaml2json and jq tools
ENV CONVERT https://github.com/bronze1man/yaml2json/raw/master/builds/linux_386/yaml2json
RUN cd /usr/local/bin &&  wget --quiet ${CONVERT} && sudo chmod a+x /usr/local/bin/yaml2json

#install jelly-fish
RUN wget --output-document - http://www.cbcb.umd.edu/software/jellyfish/jellyfish-1.1.11.tar.gz \
           | tar xzf - --directory $INSTALL_DIR  --strip-components=1
RUN cd $INSTALL_DIR && ./configure --prefix=/usr/local/bin && make && make  install 
ENV PATH ${INSTALL_DIR}bin:$PATH

RUN wget --output-document - https://github.com/DerrickWood/kraken/archive/v0.10.5-beta.tar.gz \
           | tar xzf - --directory $INSTALL_DIR  --strip-components=1

# Install the biobox file validator
RUN sudo wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | sudo tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1
ENV PATH ${PATH}:${VALIDATOR}

RUN mkdir -p /bbx/output
ADD install_kraken.sh $INSTALL_DIR
ADD run.sh /usr/local/bin/
ADD Taskfile /
RUN cd /usr/local/bin && sudo /bin/bash install_kraken.sh /usr/local/bin

ENTRYPOINT ["/usr/local/bin/run.sh"]
