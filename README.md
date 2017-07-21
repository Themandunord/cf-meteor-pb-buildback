# Meteor 1.3 deployment on Bluemix environment

Many changes has been incorporated into [Meteor](http://www.meteor.com) version 1.3.2.4. 
Instead of wrapping packages in [Atmosphere](https://atmospherejs.com/) the packages now
are installed straight from [NPM](https://www.npmjs.com/). Migration from 
AtmosphereJs to NPM caused problems deploying projects to Bluemix environment,
since during build process it creates many files but bluemix staging environemnt
has limits in place on how many files can be uploaded. As such made
[Cloud Foundary Community](https://www.cloudfoundry.org/) provided 
[buildpack](https://github.com/cloudfoundry-community/cf-meteor-buildpack) became obsolete.

## Locally compile and deploy

One of the possible ways to overcome this limitation is to build project locally upload 
tarball to bluemix and setup the rest remotely, and this buildpack does exactly that.

Based on [Community buildback](https://github.com/cloudfoundry-community/cf-meteor-buildpack)

Simply build your app locally
```
meteor build /some/path/deploy

meteor reset && meteor build ../builds/. --server-only --architecture os.linux.x86_64
```
And push it to bluemix
```
cd ../builds
cf push app_name -b https://github.com/Themandunord/cf-meteor-pb-buildback.git
```

