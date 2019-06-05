docker run -v $PWD/android-4.14-p-release/:/opt/kernel \
	-v $PWD/android-ndk:/opt/android-ndk \
	-v $PWD/androidLKM:/opt/androidLKM \
	-v $PWD/3.third-run-docker.sh:/3.third-run-docker.sh \
	-v $PWD/4.fourth-run-docker.sh:/opt/4.fourth-run-docker.sh \
	-it goldfish_android_kernel bash