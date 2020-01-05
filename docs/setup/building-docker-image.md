Follow the steps to build and run your own Docker container of wassup.

The ready-to-serve Docker image will be online later.

1. First, obtain your SSL certificate. 

You can generate a free LetsEncrypt SSL certificate for your own domain at
[`https://certbot.eff.org/`](https://certbot.eff.org/) or [`https://zerossl.com/free-ssl/#crt`](https://zerossl.com/free-ssl/#crt)

Reside the cert files where you're comfortable with for future SSL certificates on your domain. 

After that, make a copy of the cert files' folder, name it "wassup_data" (or anything you want). This will be our Wassup's data folder.
Make sure in there available two SSL certificate files: a private key file and a cert file.

2. Have a PostgreSQL server with SSL running. If not, setup one with the command:

```
docker run -d --name wassup_postgres -e POSTGRES_PASSWORD=password_here \
  -v "/path/to/server.crt:/var/lib/postgresql/server.crt:ro" \
  -v "/path/to/server.key:/var/lib/postgresql/server.key:ro" \
  postgres:alpine \
  -c ssl=on \
  -c ssl_cert_file=/var/lib/postgresql/server.crt \
  -c ssl_key_file=/var/lib/postgresql/server.key
```

3. Clone the latest Wassup code using  `git clone https://github.com/wassuphq/wassup.git`.

4. `cd wassup`

5. Build the Docker image using the command: 

`docker build -t wassup .`

6. Now the Docker image built step # 5 above can be run in a container. Remember to adjust the `--mount` path to your "wassup_data" folder, all the environment variables 
specified using the `-e` option, especially `DATABASE_URL`, along with the file names such as `privkey.pem` and `fullchain.pem` -- change those 
to your file names. Remember to change the file names and not their location.

More details about all these environment variables can be found [here](/.env.example).

```
docker run -d -p 4000:443 --name wassup --mount src=/path/to/wassup/data,dst=/root/wassupssl,type=bind \
-e APP_NAME=Wassup \
-e APP_URL=https://localhost:4000 \
-e APP_HOSTNAME=localhost \
-e MAIL_SENDER_EMAIL=support@wassupapp.com \
-e SECRET_KEY_BASE=XXXXX \
-e DATABASE_URL=postgres://postgres:password_here@localhost/wassup_app_prod \
-e GOOGLE_CLIENT_ID=XXXXXXX \
-e GOOGLE_CLIENT_SECRET=XXXXXXX \
-e GOOGLE_REDIRECT_URI=http://wassupapp.com/auth/google/callback \
-e REGISTRATION_DISABLED=false \
-e SMTP_PROVIDER_DOMAIN=XX \
-e SMTP_USERNAME=XXX \
-e SMTP_PASSWORD=XXXX \
-e SSL_KEY_PATH=/root/wassupssl/privkey.pem \
-e SSL_CERT_PATH=/root/wassupssl/fullchain.pem \
wassup
```
