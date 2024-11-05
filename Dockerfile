FROM julia:bookworm

ARG userUID=1000

RUN groupadd -g $userUID pluto && adduser --uid $userUID --gid $userUID pluto

WORKDIR /home/pluto

EXPOSE 1234

VOLUME /home/pluto/notebooks

USER pluto

RUN julia -e 'import Pkg; Pkg.add("Pluto")'

ENTRYPOINT [ "julia" ]

CMD [ "-e", "import Pluto; Pluto.run(host=\"0.0.0.0\")" ]
