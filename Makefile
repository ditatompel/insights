.PHONY: build
build:
	hugo --minify --gc --enableGitInfo --cleanDestinationDir
