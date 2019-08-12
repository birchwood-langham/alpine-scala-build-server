#!/usr/bin/env sh

if [[ ! -z ${BRANCH} ]] && [[ ! -z ${TAG} ]]; then
    echo "Cannot use both BRANCH and TAG, please use only one"
    exit 1
fi

if [[ -z ${PROJECT_PATH} ]] || [[ -z ${OUTPUT_DIR} ]]; then
    echo 'PROJECT_PATH and OUTPUT_DIR must be defined'
    exit 1
fi

if [[ -z ${CREATE_TARBALL} ]]; then
    CREATE_TARBALL=false
fi

# Set the sonatype credentials so that we can log into the sonatype Nexus repo to get dependencies
if [[ -z ${SONATYPE_HOST} ]]; then 
    sed -i 's/SONATYPE_HOST/'${SONATYPE_HOST}'/g' $HOME/.sbt/.credentials
fi

if [[ -z ${SONATYPE_USER} ]]; then
    sed -i 's/SONATYPE_USER/'${SONATYPE_USER}'/g' $HOME/.sbt/.credentials
fi

if [[ -z ${SONATYPE_PASS} ]]; then
    sed -i 's/SONATYPE_PASS/'${SONATYPE_PASS}'/g' $HOME/.sbt/.credentials
fi


if [[ -z ${USE_GITLAB} ]]; then
    if [[ -n ${TOKEN} ]]; then
        echo 'Setting redirect for private GitHub repo'
        git config --global url."https://$TOKEN@github.com".insteadOf "https://github.com"
    fi
    
    PROJECT_URL=https://github.com/${PROJECT_PATH}
else
    if [[ -n ${TOKEN} ]]; then 
        echo 'Setting redirect for private GitLab repo'
        git config --global url."https://oauth2:$TOKEN@gitlab.com".insteadOf "https://gitlab.com"
    fi

    PROJECT_URL=https://gitlab.com/${PROJECT_PATH}
fi

cd /build

PROJECT=`echo ${PROJECT_URL##*/} | cut -d '.' -f 1`

echo Cloning project from ${PROJECT_URL}

if [[ -z ${BRANCH} ]]; then
    git clone ${PROJECT_URL}
else
    echo Checking out branch ${BRANCH}
    git clone --single-branch --branch ${BRANCH} ${PROJECT_URL}
fi

cd $PROJECT

if [[ ! -z ${TAG} ]]; then 
    echo Checking out tag: ${TAG}
    git checkout tags/${TAG}
fi

## we compile and force recompile dependencies without C dependencies
sbt 'set test in assembly := {}' clean assembly
mkdir -p ${OUTPUT_DIR}
cp target/**/*.jar ${OUTPUT_DIR}/

if [[ $CREATE_TARBALL = true ]]; then
    sbt clean
    rm -rf target
    rm -rf .git

    cd ..
    tar -czf "${PROJECT}.tar.gz" ${PROJECT}
    cp "${PROJECT}.tar.gz" ${OUTPUT_DIR}/
fi
