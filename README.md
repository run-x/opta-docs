# The Opta Documentation
[![Netlify Status](https://api.netlify.com/api/v1/badges/35d23cca-0ff2-42cf-ba48-4f5b651c7255/deploy-status)](https://app.netlify.com/sites/opta-docs/deploys)

Latest Main (edge) Deploy: [https://edge.docs.opta.dev](https://edge.docs.opta.dev)

# Development

## Traditional

1. Fetch git submodules: `git submodule update --init --recursive`
1. Install hugo: `brew install hugo`
1. Install npm dependancies: `npm install`
1. Run hugo server: `hugo server`

## Docker-compose

1. Fetch git submodules: `git submodule update --init --recursive`
1. Install docker-compose and
    ```bash
    docker-compose up
    ```

You can now see the site at http://localhost:1313 Any changes you make will get instantly updated in the browser!

# Deployment
We have continuous deployment set up. Once your PR gets merged, it will automatically get deployed to https://docs.opta.dev
