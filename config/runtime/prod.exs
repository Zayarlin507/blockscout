import Config

######################
### BlockScout Web ###
######################

config :block_scout_web, BlockScoutWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  check_origin: System.get_env("CHECK_ORIGIN", "false") == "true" || false,
  http: [
    port: System.get_env("PORT") || "4000",
    protocol_options: [idle_timeout: :timer.minutes(5)]
  ],
  url: [
    scheme: System.get_env("BLOCKSCOUT_PROTOCOL") || "https",
    port: System.get_env("PORT") || "4000",
    host: System.get_env("BLOCKSCOUT_HOST") || "localhost"
  ]

########################
### Ethereum JSONRPC ###
########################

################
### Explorer ###
################

pool_size =
  if System.get_env("DATABASE_READ_ONLY_API_URL"),
    do: String.to_integer(System.get_env("POOL_SIZE", "50")),
    else: String.to_integer(System.get_env("POOL_SIZE", "40"))

# Configures the database
config :explorer, Explorer.Repo.Local,
  priv: "priv/repo",
  url: System.get_env("DATABASE_URL") || "postgresql://postgres:1234@localhost:5432/blockscout",
  username: System.get_env("DATABASE_USER") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "1234",
  database: System.get_env("DATABASE_DB") || "blockscout",
  hostname: System.get_env("DATABASE_HOSTNAME") || "localhost",
  port: System.get_env("DATABASE_PORT") || "5432",
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "50"),
  ssl: String.equivalent?(System.get_env("ECTO_USE_SSL") || "true", "true")

database_api_url =
  if System.get_env("DATABASE_READ_ONLY_API_URL"),
    do: System.get_env("DATABASE_READ_ONLY_API_URL"),
    else: System.get_env("DATABASE_URL")

pool_size_api =
  if System.get_env("DATABASE_READ_ONLY_API_URL"),
    do: String.to_integer(System.get_env("POOL_SIZE_API", "50")),
    else: String.to_integer(System.get_env("POOL_SIZE_API", "10"))

# Configures API the database
config :explorer, Explorer.Repo.Replica1,
  url: database_api_url,
  pool_size: pool_size_api,
  ssl: String.equivalent?(System.get_env("ECTO_USE_SSL") || "true", "true")

database_account_url =
  if System.get_env("ACCOUNT_DATABASE_URL"),
    do: System.get_env("ACCOUNT_DATABASE_URL"),
    else: System.get_env("DATABASE_URL")

pool_size_account = String.to_integer(System.get_env("ACCOUNT_POOL_SIZE", "50"))

# Configures Account database
config :explorer, Explorer.Repo.Account,
  url: database_account_url,
  pool_size: pool_size_account,
  ssl: String.equivalent?(System.get_env("ECTO_USE_SSL") || "true", "true")

variant =
  if is_nil(System.get_env("ETHEREUM_JSONRPC_VARIANT")) do
    "parity"
  else
    System.get_env("ETHEREUM_JSONRPC_VARIANT")
    |> String.split(".")
    |> List.last()
    |> String.downcase()
  end

Code.require_file("#{variant}.exs", "#{__DIR__}/../../apps/explorer/config/prod")

###############
### Indexer ###
###############

Code.require_file("#{variant}.exs", "#{__DIR__}/../../apps/indexer/config/prod")
