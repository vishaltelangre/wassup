<p align="center">
  <img src="https://user-images.githubusercontent.com/876195/71629118-ad39a300-2c21-11ea-80e7-33e999c756b2.png">

  <h1>Wassup</h1>

  <p align="center">
    A privacy-first open-source personal assistant to help
    <br />
    keep your personal memories and emotions together.
  </p>
  <p align="center">
    Wassup is <strong>NOT</strong> a social sharing platform where people tend
    <br />
    to fake their expressions and hide the real emotions.
  </p>
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

Did you ever want to have someone in your file
with whom you can share your inner feelings?
A feeling can be a note of any random thought,
memory of an experience or an incidence.
Well, you may already have such a person in your life.
But not EVERYTHING can be expressed ALWAYS
even with our beloved ones, too.
Right?
You might be thinking that you can write down your feelings in a diary.
You may be doing that already.
But does that diary lets you express
the exact emotions
that you feel while noting down your feelings?
Does that diary let you know exactly
how you have been feeling recently?
Does that diary help you recognize
what happened exactly that changed your mood?

Wassup can help you do all of these.
But listen, Wassup is not just a diary.
Wassup lets you express your mood
when you note something in it.
It helps you determine how your mood
has been changing recently
or during any period you ask it.
With Wassup, you can trace down any memory
that triggered a significant mood change.
Wassup offers many dumb yet powerful features like these
which a real human personal assistant,
a beloved person in your life,
a note-taking software,
a diary
or anything else
that can hardly help you to achieve the same.

Wassup's only goal is to keep you happy.
It shows you why you are not happy!

Wassup is NOT a social sharing platform like Twitter, Facebook, etc.
There is no feature such as public profile in Wassup.
There are no friends, no followers and nothing like that.
Only you can view your memories and emotions.
If you want, you can star or unstar your favorite memories.
Wassup keeps all of your information private
and offers absolutely NO WAY to share anything with anyone.

Wassup is open-source and free software.
You can always see all of its code in daylight or night.
If you don't trust the hosted version of Wassup
then you can always grab its source code
and host it yourself on your private server
or on your local computer in your backyard.
We will not ask you for a penny
for hosting it yourself
for your personal and non-commercial use.
Imagine, it is a real deal.

## Features

### Currently available features

- Simple, beautiful and responsive user interface
- Easily add notes
- Record emotions while saving notes
- Realtime dashboard
- See recently saved notes on dashboard
- See how your mood has been recently on the dashboard using helpful visual charts
- See all your past notes
- Filter notes by a (search) query
- See (filtered) notes in between any date range
- Ready made date range filters to list notes for today, yesterday, this week, this month, etc.
- Easily paginate all the notes
- A detailed mood chart
- Ability to see notes directly on the chart
- See sentiment chart between any date range of your choice
- Edit notes and mood in-place
- Easily star or unstar notes from various places
- Sign in using email and password or social sign in using your Google account
- (If you host Wassup yourself) ability to disable registration
- (If you host Wassup yourself) ability to add users directly (from command-line interface)

### Features that will be built eventually and will be available in future

- (TODO) Run in a Docker container
- (TODO) Export notes along with the mood/sentiment data
- (TODO) Import notes along with the mood/sentiment data
- (TODO) Sends you an email reminder if you haven't saved a note for a while (configurable frequency)
- (TODO) REST APIs to add, update and access your notes programmatically and securely
- (TODO) Google Chrome extension to add notes and see recent notes
- (TODO) Multi-language (internationalization) support
- (TODO) Simple desktop application to easily add notes and see recent notes
- (TODO) Native mobile application for popular platforms

## Local Development Setup

Wassup backend is built using the Elixir language
with the help of the Phoenix web framework.

Please install Elixir on your platform
by following instructions at https://elixir-lang.org/install.html.

Once Elixir is installed, you can clone this repository.

Ensure that you have a PostgreSQL server running on your computer.

1. Install Elixir dependencies with `mix deps.get`.
2. Create and migrate your database with `mix ecto.setup`.
3. Install NPM dependencies with `cd assets && npm install; cd ..`.
4. Start the Phoenix server with `mix phx.server`
   or with an interactive shell using `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000)
from your browser to access the Wassup.

Note that the seed user login credentials
can be found in [`priv/repo/seeds.exs`](./priv/repo/seeds.exs) file.

If you ever need to reset the seed data, run `mix ecto.reset`.

If you need to allow social signing in using Google,
please create a `.env` file with the following environment
variables appropriately and restart the Phoenix server.

```sh
# Variables to allow signing in using Google
export GOOGLE_CLIENT_ID="YOUR_GOOGLE_CLIENT_ID_HERE"
export GOOGLE_CLIENT_SECRET="GOOGLE_CLIENT_SECRET_HERE"
export GOOGLE_REDIRECT_URI="http://localhost:4000/auth/google/callback"
```

In the `dev` environment,
we use `Bamboo.LocalAdapter` which stores the emails
in memory
instead of sending them for real.
Check these emails anytime by visiting
[`localhost:4000/sent_emails`](http://localhost:4000/sent_emails).

## Production Setup

1. Copy all the environment variables in [`.env.example`](.env.example) and export them with appropriate values (e.g. `source .env.prod`).
2. Install production environment dependencies using `mix deps.get --only prod`.
3. Compile the Elixir code using `MIX_ENV=prod mix compile`.
4. Compile static assets with `npm run deploy --prefix ./assets` and then generate a static assets digest manifest using `mix phx.digest`.
5. Create and migrate the database using `MIX_ENV=prod mix ecto.setup` and `MIX_ENV=prod mix ecto.migrate`.
6. Start the Phoenix server using `MIX_ENV=prod mix phx.server` or in a detached or background mode using `MIX_ENV=prod elixir --erl "-detached" -S mix phx.server`.

## Monetization

Soon, we will offer a paid hosted version of Wassup
so you don't have to worry about hosting it yourself and maintaining it.
The paid version will use the same open-source code
hosted in this Github repository.
In the future, to sustain this project
we might include some advanced and additional features
in the paid version Wassup.

People who contribute to this GitHub repository
(with a pull request that adds value,
that gets merged — not a cosmetic change or a typo fix, for instance)
will also have access to the paid version for free.

Note that you can also host and run Wassup yourself.
Download the code and run it anywhere.
The choice is yours.
It will cost you nothing if you host it yourself.

## Want to contribute?

Wow, we really appreciate your help.

First,
if you don't mind,
please talk about Wassup with your family and friends.
So more people are aware of Wassup and start using it.

We welcome contributions of all sorts.

If you find any bug or facing an issue with Wassup,
please report it on [issue tracker](https://github.com/wassuphq/wassup/issues/new).

Do you want to fix a bug,
implement a feature
or fix the documentation
then feel free to fork this repository and send a pull request.
If it looks good to us,
we will surely merge your pull request.

## Team

The Wassup project is managed and maintained by
[@vishaltelangre](http://github.com/vishaltelangre).

## Thanks

- The Wassup logo (both long and short versions), favicon image as well as the branding page cover illustration is made by Priyanka Vishal Telangre.
- Vector icons used in Wassup have been download from https://openmoji.org and http://svgicons.sparkk.fr. We would like to thank the authors for these amazing icons.
- The charts are rendered using the https://www.amcharts.com library. We appreciate the authors of this powerful and beautiful chart library.

## License

Copyright (c) 2019-2020 Vishal Telangre and contributors. All Rights Reserved.

This project is licensed under the [AGPL License](LICENSE).
