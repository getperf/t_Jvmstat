#!/bin/sh

CLASSPATH=.:"$JAVA_HOME"/lib/tools.jar; export CLASSPATH
BASEDIR=`dirname $0`; export BASEDIR
export TARGET_DIR="$BASEDIR"/lib

OLDIFS=${IFS}
IFS=''
for f in `find "${TARGET_DIR}" -name "*.jar" -o -name "*.ZIP" -o -name "*.zip" 2> /dev/null`
do
	if [ -f "$f" ]; then
		CLASSPATH=${CLASSPATH}:"$f"
fi
done
IFS=${OLDIFS}
java JStatm $1 $2 $3 $4 $5

