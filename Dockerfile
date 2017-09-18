FROM perl:5.26
COPY . /app
WORKDIR /app
RUN apt-get update \
 && apt-get install build-essential libssl-dev  libxml2-dev \
 && curl -L https://cpanmin.us | perl - --sudo App::cpanminus \
 && cpanm -n --installdeps .
CMD [ "perl", "./bin/slackbot-yahoo-train-info.pl" ]
