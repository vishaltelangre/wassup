<div align="center">
  <img src="https://user-images.githubusercontent.com/876195/71629118-ad39a300-2c21-11ea-80e7-33e999c756b2.png">

  <h1>Wassup</h1>

  <p align="center">A privacy first open source personal assistant to help <br /> keep your personal memories and emotions together.</div>
  <p align="center">Wassup is <strong>NOT</strong> a social sharing platform where people tend <br /> to fake their expressions and hide the real emotions.</p>
</div>

<p align="center">
  <img src="https://user-images.githubusercontent.com/876195/71629219-5a142000-2c22-11ea-9df0-277398d3f2d6.png">
</p>

- [Why use Wassup?](#why-use-wassup)
- [Features](#features)
  - [Currently available features](#currently-available-features)
  - [Features that will be built eventually and will be available in future](#features-that-will-be-built-eventually-and-will-be-available-in-future)
- [Local Development Setup](#local-development-setup)
- [Production Setup](#production-setup)
- [Monetization](#monetization)
- [Want to contribute?](#want-to-contribute)
- [Team](#team)
- [Thanks](#thanks)
- [License](#license)

## Why use Wassup?

Did you ever wanted to have someone with whom you can share your inner feelings? Well, you may have someone already in your life. But not everything can be expressed always with our beloved, too. Agree? You might be thinking that you can write down your thoughts and experiences in a journal. But does that journal let you store the exact emotions that you felt while writing down your thoughts? Does that journal let you know exactly how you have been feeling recently? Does that journal help you recognize what happened exactly which changed your mood?

Wassup is not just a journal. Wassup asks you your mood when you save a memory (or a note) in it. It helps you determine how your mood has been changing recently or between any custom period. You can trace down any memory that triggered a significant mood change. Wassup offers many features like these which a real personal assistant, a beloved person in your life, a note-taking application, a journal or anything else can help you achieve the same.

Wassup's only goal is to keep you happy, show you why you are not happy if you are not really happy!

Note that Wassup is not a social sharing platform like Twitter, Facebook, etc. There is no feature such as public profile. There are no friends, no followers and nothing like that. You can view only your thoughts and sentiments and star or unstar if you like anything. Wassup keeps your information private and offers absolutely no way to share anything with anyone.

Wassup is open-source and absolutely free software. You can always see all of its code in daylight or night. If you don't trust our hosted version of Wassup or ever feel that your personal memories in hosted Wassup will be sold to big boys or to your wife then you can grab the source code of Wassup and host it yourself on your private server or on your local computer in your backyard. It is a real deal.

## Features

### Currently available features

- Simple, beautiful and responsive user interface
- Easily add journal notes
- Record emotions while saving notes
- Realtime dashboard
- See recently saved notes on dashboard
- See how has been your mood recently with multiple graphs from the dashboard
- See all past notes
- Filter notes by a query
- See (filtered) notes in between a date range
- Easily paginate all the notes
- See the detailed mood chart
- Ability to see notes on the charts
- See sentiment chart between a custom date range
- Edit notes in-place
- Star or unstar notes from various places easily
- Sign in using email and password or social sign in using your Google account
- (If you host Wassup yourself), ability to disable registration
- (If you host Wassup yourself), ability to add users directly (using a command)

### Features that will be built eventually and will be available in future

- (TODO) Run in a Docker container
- (TODO) Export journal notes along with the sentiment data
- (TODO) Import journal notes along with the sentiment data
- (TODO) Send an email reminder when a note hasn't been added within the defined period
- (TODO) REST APIs to create and access notes programmatically and securely
- (TODO) Google Chrome extension to add notes and see recent notes
- (TODO) Mulitple language support (Internationalization)
- (TODO) Simple desktop application to easily add notes and see recent notes
- (TODO) Native mobile application

## Local Development Setup

Wassup backend is built using the Elixir language with the help of the Phoenix web framework.

Please install Elixir on your platform by following appropriate instructions at https://elixir-lang.org/install.html.

Once Elixir is installed, you can clone this repository.

Ensure that you have a PostgreSQL server running on your computer.

1. Install dependencies with `mix deps.get`.
2. Create and migrate your database with `mix ecto.setup`.
3. Install NPM dependencies with `cd assets && npm install`.
4. Start the Phoenix server with `mix phx.server` or with an interactive shell using `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Note that the seed user login credentials can be found in [`priv/repo/seeds.exs`](./priv/repo/seeds.exs) file.

If you ever need to reset the seed data, run `mix ecto.reset`.

If you need to allow social signing in using Google, please create `.env` file with the following environment variables appropriately and restart the Phoenix server.

## Production Setup

1. Copy all environment variables in [`.env.example`](.env.example) and export them with appropriate values (e.g. `source .env.prod`).
2. Install production environment dependencies using `mix deps.get --only prod`.
3. Compile the code using `MIX_ENV=prod mix compile`.
4. Compile static assets with `npm run deploy --prefix ./assets` and then generate a static assets digest manifest using `mix phx.digest`.
5. Create and migrate the database using `MIX_ENV=prod mix ecto.setup` and `MIX_ENV=prod mix ecto.migrate`.
6. Start the Phoenix server using `MIX_ENV=prod mix phx.server` or in a detached/background mode using `MIX_ENV=prod elixir --erl "-detached" -S mix phx.server`.

## Monetization

Soon, we will offer a paid hosted version of Wassup so you don't have to worry about hosting it yourself and maintaining it. The paid version will use the same open-source code hosted in this Github repository. In the future, to sustain this project we might include some advanced and additional features in the paid version Wassup.

People who contribute to this GitHub repository (with a pull request that adds value, that gets merged—not a cosmetic change or a typo fix, for instance) will also have access to the paid version for free.

Note: you can also host and run Wassup yourself. Download the code and run it anywhere. The choice is yours. It will cost you nothing if you host it yourself.

## Want to contribute?

Wow, that's amazing.

First, can you please talk about Wassup so more people are aware of it and start using it.

We welcome contributions of all sorts. Feel free to send a pull request. If it looks good to us, we will surely merge your pull request.

## Team

The Wassup project is managed and maintained by [@vishaltelangre](http://github.com/vishaltelangre).

## Thanks

- The Wassup logo (both long and short versions) as well as favicon image is made by Priyanka Vishal Telangre.
- Vector icons used in Wassup have been download from https://openmoji.org and http://svgicons.sparkk.fr. We would like to thank the authors for these amazing icons.
- The charts are rendered using the https://www.amcharts.com library. We appreciate the authors of this powerful and beautiful chart library.

## License

Copyright (c) 2019-2020 Vishal Telangre and contributors. All Rights Reserved.

This project is licensed under the [AGPL License](LICENSE).
