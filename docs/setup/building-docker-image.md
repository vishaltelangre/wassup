Follow the steps to build and run your own Docker container of wassup.

The ready-to-serve Docker image will be online later.

0. (Required) First, obtain your SSL certificate.

0. (Optional) If you don't have a PostgreSQL server with SSL running, setup one with the command:

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

2. `cd wassup`

3. Prepare your wassup's `data` folder. It can be anywhere, just make sure to put in there 2 SSL certificate files: private key file and cert file obtained in step # 1. above. If you already have these cert files on your computer, set the environment variables `SSL_KEY_PATH` and `SSL_CERT_PATH` with the fully qualified path to these cert files accordingly.

4. Now you're ready to build.

`docker build -t wassup .`

5. Run the built image. Remember to adjust the --mount path, all the environment variables -e, especially DATABASE_URL, along with the file names (privkey.pem & fullchain.pem, change those to your file names. Remember, file names, not location).

More infomation about the environment variables is available [here](https://github.com/wassuphq/wassup/blob/master/.env.example).

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
