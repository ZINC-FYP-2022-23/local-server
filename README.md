# local-server (Production)

Production server for the entire ZINC stack powered by Docker Compose.

## URLs

Upon running this server, you can visit:

- https://zinc2023.ust.dev/ - Console UI
- (WIP) - Student UI

If you're seeing an error on first load, please append `login` to the URL (e.g. https://zinc2023.ust.dev/login). The `login` endpoint is a temporary endpoint that bypasses the HKUST OAuth login by setting a cookie.

## Initial Setup

### Prerequisites

Make sure that you can run Docker as a non-root user. Follow [this guide](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) to create a `docker` group and add yourself to the `docker` group.

### Setup Script

1. Create an empty folder to store FYP-related repos, e.g. `~/dev/fyp-prod`.
2. Open a terminal and `cd` into the folder you just created (e.g. `cd ~/dev/fyp-prod`).
3. Clone this repository: `git clone https://github.com/ZINC-FYP-2022-23/local-server.git`

   Your file directory should look something like:

   ```
   ~/dev/fyp-prod/
   └── local-server/
   ```

4. Run the setup script:

   ```sh
   # Make sure you're in the root of the cloned repo
   cd local-server/ && ./setup.sh
   ```

   The set-up script will clone other necessary repos and create new folders in the folder you created in step 1. After the script has
   finished running, your file directory should look something like:

   ```
   ~/dev/fyp-prod/
   └── console/
   └── grader/
   └── grader-daemon/         # Stores grader daemon-related files
       └── log/                 # Same as `config.properties` -> `context.logPaths.envHostRoot`
       └── out/                 # Same as `config.properties` -> `context.outPathsRoots.envHostRoot`
       └── shared/              # Same as `config.properties` -> `context.inPaths.envHostRoot`
           └── extracted/
           └── generated/
           └── helpers/
           └── submitted/
   └── hasura-server/
       └── hasura/                  # Metadata of Hasura server
       └── ...
   └── local-server/
       └── .env                     # Environmental variables for Docker Compose
       └── cloudflared-config.yml   # Cloudflared configuration file
       └── config.properties        # Grader daemon configuration file
       └── ...
   └── student-ui/
   └── webhook/
   ```

   > **Warning**
   > Do **NOT** rename the folders or change the file structure. Otherwise, the Docker Compose configuration will break.

5. Continue the set-up instructions in the below section.

### Configuration Files

The setup script created several configuration files under `local-server/`:

- `.env` - Environmental variables for Docker Compose
  - Please provide the value for `FONT_AWESOME_NPM_TOKEN`
- `cloudflared-config.yml` - Cloudflared configuration file
  - This configures `cloudflared`, which exposes our Docker compose server to the Internet via a Cloudflare domain
- `config.properties` - Grader daemon configuration file
  - Double check the paths `context.inPaths.envHostRoot`, `context.outPathsRoots.envHostRoot`, and `context.logPaths.envHostRoot` to make sure they exist on your machine

### Cloudflared

In `local-server/` folder, you should create a new file called `cloudflared-credentials.json`, which contains the credentials for the Cloudflared tunnelling service. Please contact Kris for the credentials.

### Grader Daemon Executable

1. Visit the `grader/` folder created by the setup script
2. Install Kotlin dependencies
3. Build the Grader Daemon executable with `./gradlew daemon:shadowJar`
4. Move the executable to the root of the `grader-daemon/` folder created by the setup script

   ```sh
   # Assume you're in root of `grader/` folder
   mv daemon/build/libs/zinc-grader-daemon.jar ../grader-daemon
   ```

### Console and Student UI

The codebase may hardcode the URLs of the GraphQL server, such as:

- `https://api.zinc.cse.ust.hk/v1/graphql`
- `wss://api.zinc.cse.ust.hk/v1/graphql`
- `http://localhost:8080/v1/graphql`
- `ws://localhost:8080/v1/graphql`

Please replace all occurrences of these URLs with `https://apizinc2023.ust.dev/v1/graphql` and `wss://apizinc2023.ust.dev/v1/graphql` respectively.

### Hasura Metadata Files

The `hasura-server/hasura/` folder contains Hasura metadata files, which is provided by Kris. In several files inside `hasura-server/hasura/metadata/`, you may see occurrences of the localhost address `127.0.0.1`:

```yaml
# e.g. In hasura-server/hasura/metadata/cron_triggers.yaml
webhook: http://127.0.0.1:4000/trigger/syncEnrollment
```

Unfortunately, we need to manually replace these occurrences with `webhook` (the name of the webhook service in `docker-compose.yml`), so:

```diff
- webhook: http://127.0.0.1:4000/trigger/syncEnrollment
+ webhook: http://webhook:4000/trigger/syncEnrollment
```

### Starting the Server

```sh
# 1. Change directory to root of `local-server/` folder
cd local-server/

# 2. Build the Docker images
docker compose build

# 3. Start the server
docker compose up
```

It may be possible that the `graphql-engine` containers fail to start. This is expected behavior since it's possible that `postgres` runs the database migrations after `graphql-engine` is ready. If this happens, simply stop the server and start it again.
