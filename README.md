# czechidm-docker
Official docker images for CzechIdM identity manager.

CzechIdM docker image is built atop BCV's Tomcat image. All additional modules, connectors, configuration, etc. are supposed to be built atop existing docker image, effectively creating new docker image.

## Directory structure
- **compose/** - contains simple/sample docker-compose files for image from this repo.
- **images/** - contains sources for building docker images.

## Additional info
- Release tags on this repository correspond to release tags on individual images.
- See **README.md** in [images/czechidm/](images/czechidm/) to get more information about specific docker image.
- See **README.md** in [compose/](compose/) for compose YAML files and for starting images as a part of the infrastructure.
