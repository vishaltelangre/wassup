FROM elixir:alpine
RUN apk add --no-cache git nodejs nodejs-npm build-base

WORKDIR /root/wassup
COPY . /root/wassup

ENV MIX_ENV prod
ENV APP_HOSTNAME $APP_HOSTNAME
ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV DATABASE_URL $DATABASE_URL

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get --only prod

RUN npm install --prefix ./assets
RUN npm run deploy --prefix ./assets
RUN mix phx.digest

ENV MIX_ENV prod

RUN mix compile

EXPOSE 4000/tcp
EXPOSE 443/tcp

ENTRYPOINT docker/start.sh
