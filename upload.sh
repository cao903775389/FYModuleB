#!/bin/bash

git stash
git pull origin $(git rev-parse --abbrev-ref HEAD) --tags
git stash pop

ConflicCount=$(git ls-files -u | wc -l)
if [ "$ConflicCount" -gt 0 ] ; then
   echo "git有冲突，请执行git status查看冲突文件"
   exit 1
fi

Repo="FYModuleSpec"
RepoList=("FYModuleSpec")
getRepo() {
    echo -e "\n"
    length=${#RepoList[@]}
    for ((index=0; index<length; index++)); do
        echo "  (${index}) ${RepoList[$index]}"
    done

    read -p "请选择发版组件要存放的仓库 (输入标号) :" RepoIndex

    if test $RepoIndex -lt $length; then
        Repo=${RepoList[${RepoIndex}]}
    else
        echo -e "\n\n 标号必须小于 ${length}\n"
        getRepo
    fi
}

getInfomation() {
	echo -e "\n"
    getRepo
    echo -e "\n${Default}================================================"
    echo -e "  存放仓库       :  ${Cyan}${Repo}${Default}"
    echo -e "================================================\n"
}

confirmed="n"
while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
do
    if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
        getInfomation
    fi
    read -p "信息确认? (y/n):" confirmed
done


DevelopVersionString=`grep -E 'version.develop.*=' FYModuleB.podspec`
DevelopVersionNumber=`tr -cd 0-9 <<<"$DevelopVersionString"`
NewDevelopVersionNumber=$DevelopVersionNumber

TestVersionString=`grep -E 'version.test.*=' FYModuleB.podspec`
TestVersionNumber=`tr -cd 0-9 <<<"$TestVersionString"`
NewTestVersionNumber=$TestVersionNumber

GrayVersionString=`grep -E 'version.gray.*=' FYModuleB.podspec`
GrayVersionNumber=`tr -cd 0-9 <<<"$GrayVersionString"`
NewGrayVersionNumber=$GrayVersionNumber

if [ "$Repo" == "FYModuleSpec" ]; then
  NewDevelopVersionNumber=$(($DevelopVersionNumber + 1))
  NewTestVersionNumber=0
  NewGrayVersionNumber=0
fi

DevelopVersionLineNumber=`grep -nE 'version.develop.*=' FYModuleB.podspec | cut -d : -f1`
sed -i "" "${DevelopVersionLineNumber}s/${DevelopVersionNumber}/${NewDevelopVersionNumber}/g" FYModuleB.podspec
echo "current develop version is ${DevelopVersionNumber}, new version is ${NewDevelopVersionNumber}, line number is ${DevelopVersionLineNumber}"

TestVersionLineNumber=`grep -nE 'version.test.*=' FYModuleB.podspec | cut -d : -f1`
sed -i "" "${TestVersionLineNumber}s/${TestVersionNumber}/${NewTestVersionNumber}/g" FYModuleB.podspec
echo "current test version is ${TestVersionNumber}, new version is ${NewTestVersionNumber}, line number is ${TestVersionLineNumber}"

GrayVersionLineNumber=`grep -nE 'version.gray.*=' FYModuleB.podspec | cut -d : -f1`
sed -i "" "${GrayVersionLineNumber}s/${GrayVersionNumber}/${NewGrayVersionNumber}/g" FYModuleB.podspec
echo "current gray version is ${GrayVersionNumber}, new version is ${NewGrayVersionNumber}, line number is ${GrayVersionLineNumber}"

VersionString=`grep -E 's.version.*=' FYModuleB.podspec`
VersionNumber=`echo "$VersionString" | sed 's/[^"]*"\([^"]*\)".*/\1/'`
NewVersionNumber="${NewDevelopVersionNumber}.${NewTestVersionNumber}.${NewGrayVersionNumber}"
VersionLineNumber=`grep -nE 's.version.*=' FYModuleB.podspec | cut -d : -f1`
sed -i "" "${VersionLineNumber}s/${VersionNumber}/${NewVersionNumber}/g" FYModuleB.podspec
echo "old version is ${VersionNumber}, new version is ${NewVersionNumber}, line number is ${VersionLineNumber}"

git add .
git commit -am ${NewVersionNumber}
git tag ${NewVersionNumber}
git push origin HEAD --tags
pod repo push ${Repo} FYModuleB.podspec --verbose --allow-warnings --use-libraries --use-modular-headers
