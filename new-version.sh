#!/usr/bin/env bash

# Keep the current directory
currentDir="$(pwd)"

#FlutterDir
flutterDir="$currentDir/flutter"

# Clone Flutter repository if not already cloned
if [[ -d $flutterDir ]]; then
    echo "Flutter is already cloned"
    cd "$flutterDir"
    git fetch --all -p
    cd "$currentDir"
else
    git clone git@github.com:flutter/flutter.git
fi

# Move to the flutter directory and get all tags (format is vx.x.x)
cd "$flutterDir"
versions=()
for crt_tag in $(git tag -l --sort=v:refname)
do
   versions=( "${versions[@]}" "$crt_tag" )
done
cd "$currentDir"

lastVersion="v0.0.10"
rebaseNeeded=false

for version in "${versions[@]}"; do

    if [ `git branch --list ${version}` ] || [ `git branch --list --remote origin/${version}` ]
    then
        echo "${version} already generated."
        git checkout ${version}

        if [ ${rebaseNeeded} = true ]
        then
            git rebase --onto ${lastVersion} head~ ${version} -X theirs
            diffStat=`git --no-pager diff head~ --shortstat`
            #git push origin ${version} -f
            diffUrl="[${lastVersion}...${version}](https://github.com/nartawak/flutter-cli-diff/compare/${lastVersion}...${version})"
            git checkout master
            # rewrite stats in README after rebase
            sed -i "" "/^${version}|/ d" README.md
            sed -i '' 's/----|----|----/----|----|----\
            NEWLINE/g' README.md
            sed -i "" "s@NEWLINE@${version}|${diffUrl}|${diffStat}@" README.md
            git commit -a --amend --no-edit
            git checkout ${version}
        fi

        lastVersion=${version}
        continue
    fi

    echo "Generate ${version}"
    rebaseNeeded=true
    git checkout -b ${version}

    # delete app
    rm -rf flutterdiff

    # Install flutter version
    cd "$flutterDir"
    git checkout ${version}
    cd "$currentDir"

    # Generate Flutter base project with default langage value
    ./flutter/bin/flutter create flutterdiff

    git add flutterdiff
    git commit -am "version ${version}"
    diffStat=`git --no-pager diff head~ --shortstat`
    git push origin ${version} -f

    git checkout master
    diffUrl="[${lastVersion}...${version}](https://github.com/nartawak/flutter-cli-diff/compare/${lastVersion}...${version})"
    # insert a row in the version table of the README
    sed -i "" "/^${version}|/ d" README.md
    sed -i '' 's/----|----|----/----|----|----\
    NEWLINE/g' README.md
    sed -i "" "s@NEWLINE@${version}|${diffUrl}|${diffStat}@" README.md
    # commit
    git commit -a --amend --no-edit
    git checkout ${version}
    lastVersion=${version}

done

git checkout master
git push origin master -f
