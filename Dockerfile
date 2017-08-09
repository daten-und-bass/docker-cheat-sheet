FROM <img_name>:<tag_name>  

ARG <port_env_var>
ENV NODE_ENV ${<nodejs_env>}  

RUN <some_bash_cmd> \
    && <another_bash_cmd>

COPY <file_name> /destination/path/in/container
VOLUME /source/path/on/host:/destination/path/in/container  

EXPOSE ${<port_env_var>}    # only exposed by container, but not yet mapped to the docker host  

USER <user_name>            # set permisions accordingly (before) ... if not specified: root
WORKDIR <dir_name>
CMD <main_bash_cmd>         # or ENTRYPOINT command (not overwritable) for external scripts