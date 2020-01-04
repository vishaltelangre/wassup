FROM elixir:alpine
#SHELL ["/bin/bash", "-c"]

WORKDIR /root
RUN apk --update add git nodejs nodejs-npm alpine-sdk

RUN git clone https://github.com/wassuphq/wassup.git
WORKDIR /root/wassup
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

WORKDIR /root/wassup/assets
RUN npm install
WORKDIR /root/wassup

RUN npm run deploy --prefix ./assets
RUN mix phx.digest

ENV APP_URL $APP_URL
ENV APP_HOSTNAME $APP_HOSTNAME
ENV MAIL_SENDER_EMAIL $MAIL_SENDER_EMAIL
ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV DATABASE_URL $DATABASE_URL
ENV GOOGLE_CLIENT_ID $GOOGLE_CLIENT_ID
ENV GOOGLE_CLIENT_SECRET $GOOGLE_CLIENT_SECRET
ENV GOOGLE_REDIRECT_URI $GOOGLE_REDIRECT_URI
ENV REGISTRATION_DISABLED $REGISTRATION_DISABLED
ENV SMTP_PROVIDER_DOMAIN $SMTP_PROVIDER_DOMAIN
ENV SMTP_USERNAME $SMTP_USERNAME
ENV SMTP_PASSWORD $SMTP_PASSWORD
ENV WASSUP_SSL_KEY_PATH $WASSUP_SSL_KEY_PATH
ENV WASSUP_SSL_CERT_PATH $WASSUP_SSL_CERT_PATH

COPY config/prod.exs /root/wassup/config/prod.exs
RUN MIX_ENV=prod mix compile

EXPOSE 443/tcp

COPY init.sh /root/wassup/init.sh
ENTRYPOINT ./init.sh
