
# Development

## Traditional

- Fetch git submodules: `git submodule update --init --recursive`
- Install hugo: `brew install hugo`
- Install npm dependancies: `npm install`
- Run hugo server: `hugo server`

## Docker-compose

Install docker-compose and
```bash
docker-compose up
```

You can now see the site at http://localhost:1313 Any changes you make will get instantly updated in the browser!

# Deployment
We have continuous deployment set up. Once your PR gets merged, it will automatically get deployed to https://docs.opta.dev
