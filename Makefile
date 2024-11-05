pluto-build:
	docker build -t pluto .

pluto-run: pluto-build
	docker run -it --rm -p 1234:1234 -v .:/home/pluto/notebooks pluto