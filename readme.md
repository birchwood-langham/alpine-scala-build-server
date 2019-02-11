# Alpine Linux Scala Build Server

This is a docker image that can be used to compile Scala projects created for SRL. The image should be used as part of a multi-stage
build to compile the Scala code and create a fat jar using SBT's assembly plugin. 

The jar can be copied to the target Docker image to be deployed.

To create the image, run the provided build script.

```bash
./build.sh
```
