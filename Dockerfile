FROM perl:5.26
COPY . /app
WORKDIR /app
RUN apt-get update \
 && apt-get install build-essential chrpath libssl-dev libxft-dev \
 && apt-get install libfreetype6 libfreetype6-dev \
 && apt-get install libfontconfig1 libfontconfig1-dev \
 && export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" \
 && curl -L -O https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
 && tar xvjf $PHANTOM_JS.tar.bz2 \
 && ln -sf /app/$PHANTOM_JS/bin/phantomjs /usr/bin \
 && curl -L https://cpanmin.us | perl - --sudo App::cpanminus \
 && cpanm -n --installdeps .
CMD [ "perl", "./bin/slackbot-yahoo-train-info.pl" ]
