# Purpose is to test C executable deployment via CyVerse executable (non-interactive)
FROM cexec1_2
USER ubuntu
RUN export HOME=/home/ubuntu
# add directory for iRODS iCommands to user profile as JSON, see entry.sh
RUN mkdir /home/ubuntu/.irods 
#
# Copy C executables ( portable linux versions with static build/link )
COPY spatcon_lin64 /home/ubuntu/spatcon_lin64
RUN sudo chmod +x /home/ubuntu/spatcon_lin64
COPY grayspatcon_lin64 /home/ubuntu/grayspatcon_lin64
RUN sudo chmod +x /home/ubuntu/grayspatcon_lin64
#
WORKDIR /home/ubuntu/data-store/
COPY entry.sh /home/ubuntu/entry.sh
RUN sudo chmod +x /home/ubuntu/entry.sh
ENTRYPOINT ["bash", "/home/ubuntu/entry.sh"]
