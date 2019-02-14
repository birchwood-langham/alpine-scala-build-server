#!/usr/bin/env sh

if [[ ! -z ${BRANCH} ]] && [[ ! -z ${TAG} ]]; then
    echo "Cannot use both BRANCH and TAG, please use only one"
    exit 1
fi

if [ -z ${TOKEN} ]; then
    echo "TOKEN has not been set, cannot continue"
    exit 1
fi

if [[ -z ${SONATYPE_HOST} ]] || [[ -z ${SONATYPE_USER} ]] || [[ -z ${SONATYPE_PASS} ]]; then
    echo 'SONATYPE_HOST, SONATYPE_USER and SONATYPE_PASS must be defined'
    exit 1
fi

# Set the sonatype credentials so that we can log into the sonatype Nexus repo to get dependencies
sed -i 's/SONATYPE_HOST/'${SONATYPE_HOST}'/g' $HOME/.sbt/.credentials
sed -i 's/SONATYPE_USER/'${SONATYPE_USER}'/g' $HOME/.sbt/.credentials
sed -i 's/SONATYPE_PASS/'${SONATYPE_PASS}'/g' $HOME/.sbt/.credentials

if [[ -z ${PROJECT_PATH} ]] || [[ -z ${OUTPUT_DIR} ]]; then
    echo 'PROJECT_PATH and OUTPUT_DIR must be defined'
    exit 1
else

    git config --global url."https://oauth2:$TOKEN@gitlab.com".insteadOf "https://gitlab.com"
    
    cd /build
    
    PROJECT_URL=https://gitlab.com/${PROJECT_PATH}
    PROJECT=`echo ${PROJECT_URL##*/} | cut -d '.' -f 1`

    echo Cloning project from ${PROJECT_URL}

    if [[ -z ${BRANCH} ]]; then
        git clone ${PROJECT_URL}
    else
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
    
fi
