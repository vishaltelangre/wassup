CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    MIX_ENV=prod mix ecto.setup
    MIX_ENV=prod mix ecto.migrate
fi
MIX_ENV=prod mix phx.server
