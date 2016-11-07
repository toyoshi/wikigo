[![Build Status](https://travis-ci.org/toyoshi/wikigo.svg?branch=master)](https://travis-ci.org/toyoshi/wikigo)

## wikigo

<img src='https://cloud.githubusercontent.com/assets/188394/19829766/528c7046-9e25-11e6-9271-0fa6916b770b.png' width='500'>

Wiki engine by Ruby on Rails

## Features

<img src='https://cloud.githubusercontent.com/assets/188394/19829747/d9d0b680-9e24-11e6-9d1d-40e20604f170.png' width='500'>

- Multiuser
- Markdown
- Auto keyword link

## Setup

Just deploy to Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

### Image upload

WikiGo support [Cloudinary](http://cloudinary.com/ )
Define the CLOUDINARY_URL environment variable to upload

```bash
$ heroku config:set CLOUDIONNARY_URL=cloudinary://{api_key}:{api_secret}@{cloud_name}
```
