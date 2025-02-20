# Initial process
Only run `docker-setup.sh` when setting up the server for the first time.  
Afterwards run `docker compose build`

# Running the container
Subsequently run the container with 
`docker compose up`  
To stop it, run
`docker compose down`

# Tiling Server URL
`{cloudflare-link-generated}/tile/{z}/{x}/{y}.png`
